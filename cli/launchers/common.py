"""Shared process helpers for installed client CLI launchers."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import time
from collections.abc import Mapping
from contextlib import contextmanager
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

from cli.process_registry import (
    kill_pid_tree_best_effort,
    register_pid,
    unregister_pid,
)

PROXY_PREFLIGHT_PATH = "/health"
PROXY_PREFLIGHT_TIMEOUT_SECONDS = 1.5
PROXY_STARTUP_TIMEOUT_SECONDS = 20.0
PROXY_STARTUP_POLL_INTERVAL_SECONDS = 0.25
SERVER_BINARY_NAME = "cfc-server"
SERVER_DISPLAY_NAME = "Chinna-Free-Claude proxy"
SERVER_INSTALL_HINT = "Install Chinna-Free-Claude so cfc-server is on PATH."


def preflight_proxy(proxy_root_url: str) -> str | None:
    """Return an error message when the local proxy health check is unreachable."""

    url = f"{proxy_root_url.rstrip('/')}{PROXY_PREFLIGHT_PATH}"
    request = Request(url, method="GET")
    try:
        with urlopen(request, timeout=PROXY_PREFLIGHT_TIMEOUT_SECONDS) as response:
            status_code = response.getcode()
    except HTTPError as exc:
        return f"returned HTTP {exc.code}"
    except URLError as exc:
        return str(exc.reason)
    except OSError as exc:
        return str(exc)

    if not 200 <= status_code < 300:
        return f"returned HTTP {status_code}"
    return None


@contextmanager
def ensure_proxy_running(proxy_root_url: str):
    """Yield after the local proxy is healthy, starting it if needed."""

    if preflight_proxy(proxy_root_url) is None:
        yield
        return

    print(
        "Chinna-Free-Claude proxy is not reachable; starting cfc-server for this "
        f"session at {proxy_root_url}",
        file=sys.stderr,
    )
    server_command = resolve_client_binary(
        binary_name=SERVER_BINARY_NAME,
        display_name=SERVER_DISPLAY_NAME,
        install_hint=SERVER_INSTALL_HINT,
    )
    process = subprocess.Popen([server_command], env=os.environ.copy())
    if process.pid:
        register_pid(process.pid)

    try:
        error = _wait_for_proxy_ready(proxy_root_url, process)
        if error is not None:
            raise SystemExit(
                f"Could not start {SERVER_BINARY_NAME} for {proxy_root_url}: {error}"
            )
        yield
    finally:
        if process.pid:
            if process.poll() is None:
                kill_pid_tree_best_effort(process.pid)
            process.wait()
            unregister_pid(process.pid)


def _wait_for_proxy_ready(
    proxy_root_url: str, process: subprocess.Popen[bytes]
) -> str | None:
    """Wait until the local proxy health check succeeds or the server exits."""

    deadline = time.monotonic() + PROXY_STARTUP_TIMEOUT_SECONDS
    last_error = "timed out waiting for cfc-server to become healthy"

    while time.monotonic() < deadline:
        if process.poll() is not None:
            return f"exited with code {process.returncode}"
        if preflight_proxy(proxy_root_url) is None:
            return None
        time.sleep(PROXY_STARTUP_POLL_INTERVAL_SECONDS)

    return last_error


def resolve_client_binary(
    *,
    binary_name: str,
    display_name: str,
    install_hint: str,
) -> str:
    """Resolve an installed client binary or exit with a user-facing hint."""

    client_command = shutil.which(binary_name)
    if client_command is None:
        print(
            f"Could not find {display_name} command: {binary_name}",
            file=sys.stderr,
        )
        print(install_hint, file=sys.stderr)
        raise SystemExit(127)
    return client_command


def run_client_process(
    *,
    command: list[str],
    env: Mapping[str, str],
    binary_name: str,
    display_name: str,
    install_hint: str,
) -> None:
    """Run a client CLI command and mirror its exit code."""

    process: subprocess.Popen[bytes] | None = None
    try:
        process = subprocess.Popen(command, env=dict(env))
        if process.pid:
            register_pid(process.pid)
        return_code = process.wait()
    except FileNotFoundError:
        print(
            f"Could not find {display_name} command: {binary_name}",
            file=sys.stderr,
        )
        print(install_hint, file=sys.stderr)
        raise SystemExit(127) from None
    except KeyboardInterrupt:
        if process is not None and process.pid:
            kill_pid_tree_best_effort(process.pid)
            process.wait()
        raise
    finally:
        if process is not None and process.pid:
            unregister_pid(process.pid)

    raise SystemExit(return_code)
