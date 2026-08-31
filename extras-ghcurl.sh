# ghcurl —— GitHub 链接自动套用 gh-proxy-manager 的加速前缀（未开启时退化为普通 curl）
# 由 gh-proxy-manager v2.2.0 提供；粘贴到 ~/.bashrc 末尾即可
ghcurl(){
  local p url="$1" rest tail
  p="$(cat /etc/gh-proxy/prefix 2>/dev/null)"
  if [[ "$url" == *raw.githubusercontent.com/* ]] && [ -f /etc/gh-proxy/jsdelivr ]; then
      rest="${url#https://raw.githubusercontent.com/}"
      tail="${rest#*/*/}"
      if [[ "$tail" != "$rest" && "$tail" == */* ]]; then
          url="https://cdn.jsdelivr.net/gh/${rest%"$tail"}${tail#*/}"   # 去掉分支段
      fi
  elif [ "$url" != "${url/github.com/}" ] && [ -n "$p" ]; then
      url="${p}${url}"
  fi
  shift
  curl -L -O "$@" "$url"
}
