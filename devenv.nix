{ pkgs, ... }: {
  languages.zig = {
    enable = true;
    version = "0.16.0";
  };

  packages = [
    pkgs.curl
    pkgs.jq
  ];

  enterShell = ''
    echo "SiteProbe Zig training day"
    echo "  zig version: $(zig version)"
    echo "  zig build run   — start API on :8080"
    echo "  zig build test  — run unit tests"
  '';

  enterTest = ''
    zig build test
    zig build run &
    server_pid=$!
    trap "kill $server_pid 2>/dev/null || true" EXIT
    wait_for_port 8080
    curl -sf http://127.0.0.1:8080/health | jq -e '.status == "ok"'
  '';
}
