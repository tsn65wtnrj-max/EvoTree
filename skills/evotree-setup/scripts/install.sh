#!/bin/sh
# Exact generated profile; invoked by Codex, never an autonomous startup hook.
set -eu
LC_ALL=C; export LC_ALL
unset CDPATH ENV BASH_ENV
umask 077
stage= child= timer= guard=
finished=false
stop_children() {
    for pid in "$child" "$timer" "$guard"; do
        if [ -n "$pid" ]; then kill -TERM "$pid" 2>/dev/null || :; wait "$pid" 2>/dev/null || :; fi
    done
    child= timer= guard=
}
block() {
    trap '' HUP INT TERM USR1
    stop_children
    # Incomplete or unexpected stages are retained. Never rm -rf as a fallback.
    finished=true
    printf '{"status":"blocked","code":"%s","stage_retained":%s}\n' "$1" "${retained:-false}"
    exit 1
}
trap 'block setup_interrupted' HUP INT TERM
trap 'block setup_deadline' USR1
trap 'stop_children; if [ "$finished" = false ]; then printf '\''{"status":"blocked","code":"setup_failed","stage_retained":%s}\n'\'' "${retained:-false}"; fi' EXIT
safe_path() { case "$1" in /*) ;; *) return 1;; esac; case "$1" in *'
'*|*'	'*) return 1;; esac; }
physical_dir() { safe_path "$1" && [ -d "$1" ] && [ ! -L "$1" ] && [ "$(cd "$1" && /bin/pwd -P)" = "$1" ]; }
identity() { /usr/bin/stat -f '%d:%i:%u:%Lp' "$1"; }
owned_file() {
    [ -f "$1" ] && [ ! -L "$1" ] &&
    [ "$(/usr/bin/stat -f %u "$1")" = "$uid" ] &&
    [ "$(/usr/bin/stat -f %l "$1")" = 1 ] &&
    [ "$(/usr/bin/stat -f '%Sp' "$1" | /usr/bin/cut -c6,9)" = '--' ]
}
digest() { value=$(/usr/bin/openssl dgst -sha256 "$1" 2>/dev/null) || return 1; printf '%s' "${value##* }"; }
metadata() {
    names=$(/usr/bin/xattr "$1" 2>/dev/null) || block archive_security_metadata_unavailable
    [ "${#names}" -le 16384 ] || block archive_security_metadata_unavailable
    if printf '%s\n' "$names" | /usr/bin/grep -Fqx com.apple.quarantine; then block quarantined_archive_requires_platform_review; fi
}
bounded() {
    limit=$1; shift
    "$@" & child=$!
    # TERM trap kills and reaps the timer's sleep as well; no orphaned timer.
    (sleep_pid=; trap 'if [ -n "$sleep_pid" ]; then kill -TERM "$sleep_pid" 2>/dev/null || :; wait "$sleep_pid" 2>/dev/null || :; fi; exit' TERM
     /bin/sleep "$limit" & sleep_pid=$!; wait "$sleep_pid";
     kill -TERM "$child" 2>/dev/null || :;
     /bin/sleep 1 & sleep_pid=$!; wait "$sleep_pid"; kill -KILL "$child" 2>/dev/null || :) & timer=$!
    rc=0; wait "$child" || rc=$?
    child=
    kill -TERM "$timer" 2>/dev/null || :; wait "$timer" 2>/dev/null || :; timer=
    return "$rc"
}
uid=$(/usr/bin/id -u)
[ "$(/usr/bin/uname -s)" = Darwin ] && [ "$(/usr/bin/uname -m)" = arm64 ] || block unsupported_native_host
major=$(/usr/bin/sw_vers -productVersion); major=${major%%.*}
[ "$major" -ge 26 ] || block unsupported_native_host
root= confirmed=false download=false
while [ "$#" -gt 0 ]; do
    case "$1" in
        --root) [ -z "$root" ] && [ "$#" -ge 2 ] || block invalid_arguments; root=$2; shift 2;;
        --confirm-install) [ "$confirmed" = false ] || block invalid_arguments; confirmed=true; shift;;
        --confirm-download) [ "$download" = false ] || block invalid_arguments; download=true; shift;;
        *) block invalid_arguments;;
    esac
done
[ "$confirmed" = true ] || block confirmation_required
physical_dir "$root" && [ "$(/usr/bin/stat -f %u "$root")" = "$uid" ] || block unsafe_project_root
root_identity=$(identity "$root")
safe_path "$0" && [ ! -L "$0" ] || block setup_integrity
scripts=${0%/*}; physical_dir "$scripts" || block setup_integrity
skill=${scripts%/*}; physical_dir "$skill" || block setup_integrity
owned_file "$skill/channel.json" || block profile_integrity
[ "$(digest "$skill/channel.json")" = 'e0685a792a349468933b3cd803884c8ccdca12cbd4e0f31d924d2c1b1973368b' ] || block profile_integrity
mode='download'
url='https://evotree-downloads.pages.dev/artifacts/57780cd02eeebd1ce76117594375ab84ae05e34495f0410a337ce3b0bb0dc2e3/evotree-0.7.0-dev.69-english-candidate-r3.zip'
if [ "$mode" = download ]; then
    [ "$download" = true ] || block download_confirmation_required
    [ -n "$url" ] || block endpoint_unbound
fi
stage=$(/usr/bin/mktemp -d /private/tmp/evotree-setup40.XXXXXXXX) || block stage_create_failed
retained=true
stage_identity=$(identity "$stage")
device=$(/usr/bin/stat -f %d "$stage")
# Finite entire setup in addition to curl and native-child limits.
(sleep_pid=; trap 'if [ -n "$sleep_pid" ]; then kill -TERM "$sleep_pid" 2>/dev/null || :; wait "$sleep_pid" 2>/dev/null || :; fi; exit' TERM
 /bin/sleep 65 & sleep_pid=$!; wait "$sleep_pid"; kill -USR1 "$$") & guard=$!
archive=$stage/core.zip
source_identity=
if [ "$mode" = bundled ]; then
    source=$skill/assets/evotree-0.7.0-dev.69-english-candidate-r3.zip
    physical_dir "$skill/assets" && owned_file "$source" || block unsafe_archive_file
    source_identity=$(identity "$source")
    metadata "$source"
    [ "$(/usr/bin/stat -f %z "$source")" = '11349992' ] || block archive_size
    [ "$(digest "$source")" = '57780cd02eeebd1ce76117594375ab84ae05e34495f0410a337ce3b0bb0dc2e3' ] || block archive_hash
    # Bounded private byte copy even if a same-user writer grows the source.
    # Original metadata remains checked and is never removed or modified.
    /bin/dd if="$source" of="$archive" bs=131072 count=87 2>/dev/null || block archive_copy_failed
    /bin/chmod 600 "$archive"
    [ "$(identity "$source")" = "$source_identity" ] || block source_changed
    metadata "$source"
else
    # Endpoint and all command options are generated from an exact reviewed profile.
    # -q first ignores ~/.curlrc; no redirects/proxy/netrc/cookies/retries, TLS verified.
    (ulimit -f 24576
     exec /usr/bin/curl -q --silent --show-error --fail --proto '=https' --proto-redir '=https' \
       --noproxy '*' --proxy '' --connect-timeout 5 --max-time 20 --max-redirs 0 \
       --max-filesize 11349992 --header 'Accept-Encoding: identity' \
       --dump-header "$stage/headers" --output "$archive" --write-out '%{http_code}' "$url") > "$stage/http-code" 2>/dev/null & child=$!
    rc=0; wait "$child" || rc=$?; child=
    [ "$rc" -eq 0 ] || block transport_failed
    [ "$(/usr/bin/stat -f %z "$stage/headers")" -le 16384 ] || block response_rejected
    [ "$(/bin/cat "$stage/http-code")" = 200 ] || block response_rejected
    # Strict HTTP/1.x final response, single Content-Length, no encodings/ranges.
    /usr/bin/awk 'BEGIN{n=0;bad=0} {sub(/\r$/, "");l=tolower($0);
      if(l ~ /^http\//){n++; if($2!="200")bad=1}
      if(l ~ /^content-length:/){cl++;if(l!="content-length: 11349992")bad=1}
      if(l ~ /^(transfer-encoding|content-range):/)bad=1;
      if(l ~ /^content-encoding:/ && l!="content-encoding: identity")bad=1}
      END{exit !(n==1 && cl==1 && bad==0)}' "$stage/headers" || block response_rejected
    headers_identity=$(identity "$stage/headers"); headers_hash=$(digest "$stage/headers")
    code_identity=$(identity "$stage/http-code"); code_hash=$(digest "$stage/http-code")
fi
owned_file "$archive" || block unsafe_archive_file
[ "$(/usr/bin/stat -f %z "$archive")" = '11349992' ] || block archive_size
metadata "$archive"
[ "$(digest "$archive")" = '57780cd02eeebd1ce76117594375ab84ae05e34495f0410a337ce3b0bb0dc2e3' ] || block archive_hash
archive_identity=$(identity "$archive")
metadata "$archive"
/bin/mkdir -m 700 "$stage/payload"
# Full ZIP digest pins safe exact entries, sizes and modes; not arbitrary extraction.
bounded 10 /usr/bin/unzip -q "$archive" -d "$stage/payload" || block extract_failed
verify_payload() {
    physical_dir "$stage" && [ "$(identity "$stage")" = "$stage_identity" ] || return 1
    [ "$(/usr/bin/find -P "$stage/payload" -print | /usr/bin/wc -l | /usr/bin/tr -d ' ')" = '66' ] || return 1
    while IFS=' ' read -r kind perms size hash name; do
        p=$stage/payload/$name
        [ ! -L "$p" ] && [ "$(/usr/bin/stat -f %d "$p")" = "$device" ] &&
            [ "$(/usr/bin/stat -f %u "$p")" = "$uid" ] || return 1
        if [ "$kind" = d ]; then
            physical_dir "$p" && [ "$(/usr/bin/stat -f %Lp "$p")" = "$perms" ] || return 1
        else
            owned_file "$p" && [ "$(/usr/bin/stat -f %Lp "$p")" = "$perms" ] &&
                [ "$(/usr/bin/stat -f %z "$p")" = "$size" ] && [ "$(digest "$p")" = "$hash" ] || return 1
        fi
    done <<'EVOTREE_EXACT_INVENTORY'
d 700 0 - evotree
d 700 0 - evotree/agents
d 700 0 - evotree/assets
d 700 0 - evotree/assets/evotree
d 700 0 - evotree/assets/evotree/gate4a
d 700 0 - evotree/assets/evotree/gate4a/web
d 700 0 - evotree/licenses
d 700 0 - evotree/licenses/third-party
d 700 0 - evotree/licenses/third-party/nuitka
d 700 0 - evotree/licenses/third-party/python
d 700 0 - evotree/references
d 700 0 - evotree/scripts
f 644 23341 91300e960f4cee137ef787648c0bc20776166ae5edc2da0a72a0d4945f412203 evotree/LICENSE-MAP.json
f 644 607 c6099558b952ec01d294188e82d18ac6e79ab81c35b98a258857e46c1b33dcaf evotree/LICENSE-STATUS.md
f 644 12808 70892b880b3ca3c86cad04435dacfb17045b60782a04d755bd5ba6a12a008868 evotree/MANIFEST.json
f 644 5862 13e346c151a65730e63f216526521c2c9516555d58fe56447cdd8e9d70f6189f evotree/SKILL.md
f 644 1331 1c9a66f83387b06774afd66336170669bcc894514679a88dba9fc7ea1c9aee48 evotree/THIRD_PARTY_NOTICES.md
f 644 250 a3a6f93385a4ae6ebbe17b3d9debe104fc01a2dc7643ffab628635c25fceec6a evotree/agents/openai.yaml
f 755 10742368 9b7962b190a73069d419ea1b11af93b3af286fe90dbdc0df6e0afbd2bc3a4c5c evotree/assets/evotree/evotree-core
f 644 26835 03cdc8787758837cc39d0a9d85daad3d2c8672bf95a76f94685a52fbfd411db1 evotree/assets/evotree/gate4a/web/app.js
f 644 5635 5d2d1d686ee737251b6843f31131f2864c1ebd0de89c9a9abac632d2a95dc11e evotree/assets/evotree/gate4a/web/index.html
f 644 14895 54614210c5a6a2e235d0550ba49eae3d53d2ddf2f14a6982cffb359a851d87ea evotree/assets/evotree/gate4a/web/model.js
f 644 1179 abcb663d19d0271e1542d8308c911b1c671ebd9741cc8c4df6b84942327d759d evotree/assets/evotree/gate4a/web/session.js
f 644 10776 8acfdff7988dc313331f07e76dd821f93e98027f7b076a20791843952e0e3155 evotree/assets/evotree/gate4a/web/style.css
f 644 1467 a262fbd5ec506db25e562f93e5fc0218cfaf3e430f83db12e7a37c9768b07704 evotree/assets/evotree/gate4a/web/themes.css
f 644 1493 27b7fec377f16f0301a20dd0a4f5b837388561a93a6072fba2247ea2dab5d5e8 evotree/assets/evotree/gate4a/web/themes.js
f 644 17954960 78daea234c6be46c02a3afc619584ab7a546e25f5bb9646a705d1b74025da55e evotree/assets/evotree/libpython3.12.dylib
f 644 4737 2cb1b4bb6bd524278b30c75719265c3f11dba39ea38a458ce9f89a4cd3ddc41f evotree/licenses/EVOTREE-FREE-LOCAL.md
f 644 5229 ed3f49b033ede52d535fad42623cc18fc288729c1c2971180225e9ceb4247308 evotree/licenses/third-party/COMPONENTS.json
f 644 2769 f85e84d3524283358debbdbb267e9eedffb6ea033b884303d16af9363e43b88d evotree/licenses/third-party/MANIFEST.json
f 644 2649 20ff0ae581adf436a7b06e50e67a6c8913aec1ea4e60dba138d0a0bee7ee520c evotree/licenses/third-party/nuitka/LICENSE-RUNTIME.txt
f 644 34523 0d96a4ff68ad6d4b6f1f30f713b18d5184912ba8dd389f86aa7710db079abcb0 evotree/licenses/third-party/nuitka/LICENSE.txt
f 644 283 b6ba5212864ec9f98842220e01b2485a2ebeb8eafa192b016b36032355c8a98d evotree/licenses/third-party/nuitka/NOTICE.txt
f 644 1002 845efc77857d485d91fb3e0b884aaa929368c717ae8186b66fe1ed2495753243 evotree/licenses/third-party/nuitka/ZLIB-LICENSE.txt
f 644 7048 a2010f343487d3f7618affe54f789f5487602331c0a8d03f49e9a7c547cf0499 evotree/licenses/third-party/python/CC0-1.0.txt
f 644 519 a27d7169aa4b7db350c5e46da87184c4b7a8ac8e4d86dce38845fdffd789d7b5 evotree/licenses/third-party/python/CPYTHON-BLAKE2-NOTICE.txt
f 644 1207 998ce04fb8ad9dedb0bc1b44938f8c3dcf1089780fa105ce1c8c30fb5554d78c evotree/licenses/third-party/python/CPYTHON-HACL-LICENSE.txt
f 644 784 7d154902ce6b110e99f48b47cc817ff8316cee2cd80795547a4658ec086bf6dc evotree/licenses/third-party/python/CPYTHON-PSTATS-NOTICE.txt
f 644 54130 341832873fd316a37927e79385093fbbfd40a467428480835fe435a80cadf4e5 evotree/licenses/third-party/python/INCORPORATED-LICENSES.rst
f 644 1743 1f38bbc7caacafd65169276d759c0d88c991b753b643ce35d0e45ea1971dd441 evotree/licenses/third-party/python/LICENSE.bzip2.txt
f 644 36164 86e61415828a8b5b06ec8d024e6f086ce155a8b85fd0c419c0ba4dc004e74fdd evotree/licenses/third-party/python/LICENSE.cpython.txt
f 644 1144 122f2c27000472a201d337b9b31f7eb2b52d091b02857061a8880371612d9534 evotree/licenses/third-party/python/LICENSE.expat.txt
f 644 1132 deaf3a42effb551a5b140fa9afefed183a27f1341c6d1bf430d106a5e6931fc0 evotree/licenses/third-party/python/LICENSE.libffi.txt
f 644 660 9a4062de0a2c388a98cf35a35d348b62fa97c838a71c3c28ee1a2d7d0a565b02 evotree/licenses/third-party/python/LICENSE.liblzma.txt
f 644 1432 122ee1f7e258f2c3c0e538a75c037684f420454bf3850ddc74ce750bbf5fe86b evotree/licenses/third-party/python/LICENSE.libuuid.txt
f 644 1284 669512af7219f58be03a398766d7c9da11a3b3df9d3f05cb74c5ceca25c8da3b evotree/licenses/third-party/python/LICENSE.mpdecimal.txt
f 644 6120 9c04cce50c4989d5601dd8b07f6ab922c40388b66ac736c9007cb1ed9d9dd560 evotree/licenses/third-party/python/LICENSE.openssl-1.1.txt
f 644 10175 7d5450cb2d142651b8afa315b5f238efc805dad827d91ba367d8516bc9d49e7a evotree/licenses/third-party/python/LICENSE.openssl-3.txt
f 644 1481 38bef3d28b24f145ea293bd3b6eb4b20396982abc8303128fb493986ea5bc719 evotree/licenses/third-party/python/LICENSE.sqlite.txt
f 644 3827 7683cca4c350631137a9e3e46387d2c068c279e4dfb6a8d5d3d4b6a82105fbef evotree/references/AUTONOMY.md
f 644 1863 d49e7ee757631c38725525d7ede9115b41201cda308fcd3b0b3e6bdb473ab6af evotree/references/CODEX_EXECUTION.md
f 644 2835 0f2fcf8bb1f0702ce51913acb9f50eca4cdb2263a9eec54648ffe9c2f7272d13 evotree/references/CONTEXT_VIEWS.md
f 644 4960 9384ccb45fec57f551d9c922acfece3ce450b7a2747a2d1ddc905e1eab8c85a9 evotree/references/EVIDENCE.md
f 644 7464 2a5861c701dee035a674c6f0ba70aec62fc7cb0c7f35d8303b22f9f5f33353a7 evotree/references/INSTALLATION.md
f 644 3267 72d4ebe277c24b293b5488a1da43f515d40b38bee3f9cca6176e48a6a8b357d6 evotree/references/LOGIN.md
f 644 1020 97d169eb23834bb0077c4c1f013ca1c8b3e41e8e832ff960b44c9405f3f0aa18 evotree/references/NATIVE.md
f 644 10329 cc12a21ac67e33a55474f4ba5c91d65f79f4c78451b86932cfd58621a3e806d6 evotree/references/OPERATION.md
f 644 7911 015c081b2067a2f26fde478e5326b295906f8ff890a301346171d6ab2a349e08 evotree/references/PROTOCOL.md
f 644 8666 2420467b992d4f5fddb60ea25e01547047b86fbce463e84037983672afdb88fc evotree/references/SESSION_CONSENT.md
f 644 157 57baea873f7496cb3fcc7f2f50beee212832a4040cc9ddc2b283e745b8096996 evotree/references/TEST_PROMPTS.json
f 644 2960 c62255e90c1883ed4f8373f50faca72d31c98533bac86cf035141446ffd01396 evotree/references/UPDATES.md
f 644 1013 a614b2427e9d33163364ff8bdb334606dd3d609dfffb60189da95e14e08d52ae evotree/scripts/_bootstrap.py
f 644 497 eee244e3f929a6e5b0b74c2e9d04a3bb9d7686508dc3bb8f892a8c1a8bc7f085 evotree/scripts/evotree.py
f 644 498 bde0d4b7b91227f922dd4714e0ba84a1e91ddeb86ba45bb88ffc83bd29191a7f evotree/scripts/producer.py
f 644 497 5a0e7bd6be99b4b947a4c67f3d0c6d369e79cf649b492521973d1de071a7012d evotree/scripts/project.py
EVOTREE_EXACT_INVENTORY
}
# unzip directory modes depend on the caller umask. Pin only already-known dirs.
physical_dir "$stage/payload/evotree" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree"
physical_dir "$stage/payload/evotree/agents" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree/agents")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree/agents")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree/agents"
physical_dir "$stage/payload/evotree/assets" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree/assets")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree/assets")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree/assets"
physical_dir "$stage/payload/evotree/assets/evotree" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree/assets/evotree")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree/assets/evotree")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree/assets/evotree"
physical_dir "$stage/payload/evotree/assets/evotree/gate4a" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree/assets/evotree/gate4a")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree/assets/evotree/gate4a")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree/assets/evotree/gate4a"
physical_dir "$stage/payload/evotree/assets/evotree/gate4a/web" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree/assets/evotree/gate4a/web")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree/assets/evotree/gate4a/web")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree/assets/evotree/gate4a/web"
physical_dir "$stage/payload/evotree/licenses" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree/licenses")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree/licenses")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree/licenses"
physical_dir "$stage/payload/evotree/licenses/third-party" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree/licenses/third-party")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree/licenses/third-party")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree/licenses/third-party"
physical_dir "$stage/payload/evotree/licenses/third-party/nuitka" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree/licenses/third-party/nuitka")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree/licenses/third-party/nuitka")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree/licenses/third-party/nuitka"
physical_dir "$stage/payload/evotree/licenses/third-party/python" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree/licenses/third-party/python")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree/licenses/third-party/python")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree/licenses/third-party/python"
physical_dir "$stage/payload/evotree/references" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree/references")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree/references")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree/references"
physical_dir "$stage/payload/evotree/scripts" && [ "$(/usr/bin/stat -f %d "$stage/payload/evotree/scripts")" = "$device" ] && [ "$(/usr/bin/stat -f %u "$stage/payload/evotree/scripts")" = "$uid" ] || block payload_integrity
/bin/chmod 700 "$stage/payload/evotree/scripts"
verify_payload || block payload_integrity
[ "$(identity "$archive")" = "$archive_identity" ] && [ "$(digest "$archive")" = '57780cd02eeebd1ce76117594375ab84ae05e34495f0410a337ce3b0bb0dc2e3' ] || block source_changed
metadata "$archive"
if [ "$mode" = bundled ]; then
    owned_file "$source" && [ "$(identity "$source")" = "$source_identity" ] && [ "$(digest "$source")" = '57780cd02eeebd1ce76117594375ab84ae05e34495f0410a337ce3b0bb0dc2e3' ] || block source_changed
    metadata "$source"
fi
physical_dir "$root" && [ "$(identity "$root")" = "$root_identity" ] || block project_changed
# Keep the bounded child in this shell, so signal traps can terminate/reap it.
# Read the trusted, fixed native command's output only after a size check.
# A process-wide RLIMIT_FSIZE here would also truncate the installed binary.
bounded 30 "$stage/payload/evotree/assets/evotree/evotree-core" project install \
    --root "$root" --confirm-install --manifest-sha256 '70892b880b3ca3c86cad04435dacfb17045b60782a04d755bd5ba6a12a008868' > "$stage/result" 2>/dev/null || block core_install_failed
owned_file "$stage/result" && [ "$(/usr/bin/stat -f %z "$stage/result")" -le 16384 ] || block core_install_result
result_identity=$(identity "$stage/result"); result_hash=$(digest "$stage/result")
result=$(/bin/cat "$stage/result")
# Never claim success if unexpected contents/metadata appeared during execution.
verify_payload || block stage_cleanup_blocked
expected_top=3
[ "$mode" = bundled ] || expected_top=5
[ "$(/usr/bin/find -P "$stage" -mindepth 1 -maxdepth 1 -print | /usr/bin/wc -l | /usr/bin/tr -d ' ')" = "$expected_top" ] || block stage_cleanup_blocked
owned_file "$archive" && [ "$(identity "$archive")" = "$archive_identity" ] && [ "$(digest "$archive")" = '57780cd02eeebd1ce76117594375ab84ae05e34495f0410a337ce3b0bb0dc2e3' ] || block stage_cleanup_blocked
metadata "$archive"
owned_file "$stage/result" && [ "$(identity "$stage/result")" = "$result_identity" ] && [ "$(digest "$stage/result")" = "$result_hash" ] || block stage_cleanup_blocked
if [ "$mode" = download ]; then
    for f in headers http-code; do owned_file "$stage/$f" && [ "$(/usr/bin/stat -f %Lp "$stage/$f")" = 600 ] || block stage_cleanup_blocked; done
    [ "$(identity "$stage/headers")" = "$headers_identity" ] && [ "$(digest "$stage/headers")" = "$headers_hash" ] &&
        [ "$(identity "$stage/http-code")" = "$code_identity" ] && [ "$(digest "$stage/http-code")" = "$code_hash" ] || block stage_cleanup_blocked
fi
# Exact complete inventory verified above; remove only named files and empty dirs.
/bin/rm "$stage/payload/evotree/LICENSE-MAP.json" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/LICENSE-STATUS.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/MANIFEST.json" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/SKILL.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/THIRD_PARTY_NOTICES.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/agents/openai.yaml" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/assets/evotree/evotree-core" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/assets/evotree/gate4a/web/app.js" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/assets/evotree/gate4a/web/index.html" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/assets/evotree/gate4a/web/model.js" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/assets/evotree/gate4a/web/session.js" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/assets/evotree/gate4a/web/style.css" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/assets/evotree/gate4a/web/themes.css" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/assets/evotree/gate4a/web/themes.js" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/assets/evotree/libpython3.12.dylib" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/EVOTREE-FREE-LOCAL.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/COMPONENTS.json" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/MANIFEST.json" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/nuitka/LICENSE-RUNTIME.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/nuitka/LICENSE.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/nuitka/NOTICE.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/nuitka/ZLIB-LICENSE.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/CC0-1.0.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/CPYTHON-BLAKE2-NOTICE.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/CPYTHON-HACL-LICENSE.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/CPYTHON-PSTATS-NOTICE.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/INCORPORATED-LICENSES.rst" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/LICENSE.bzip2.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/LICENSE.cpython.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/LICENSE.expat.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/LICENSE.libffi.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/LICENSE.liblzma.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/LICENSE.libuuid.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/LICENSE.mpdecimal.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/LICENSE.openssl-1.1.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/LICENSE.openssl-3.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/licenses/third-party/python/LICENSE.sqlite.txt" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/AUTONOMY.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/CODEX_EXECUTION.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/CONTEXT_VIEWS.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/EVIDENCE.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/INSTALLATION.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/LOGIN.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/NATIVE.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/OPERATION.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/PROTOCOL.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/SESSION_CONSENT.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/TEST_PROMPTS.json" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/references/UPDATES.md" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/scripts/_bootstrap.py" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/scripts/evotree.py" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/scripts/producer.py" || block stage_cleanup_blocked
/bin/rm "$stage/payload/evotree/scripts/project.py" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree/assets/evotree/gate4a/web" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree/assets/evotree/gate4a" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree/licenses/third-party/nuitka" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree/licenses/third-party/python" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree/assets/evotree" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree/licenses/third-party" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree/agents" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree/assets" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree/licenses" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree/references" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree/scripts" || block stage_cleanup_blocked
/bin/rmdir "$stage/payload/evotree" || block stage_cleanup_blocked
/bin/rm "$archive" || block stage_cleanup_blocked
/bin/rm "$stage/result" || block stage_cleanup_blocked
if [ "$mode" = download ]; then /bin/rm "$stage/headers" "$stage/http-code" || block stage_cleanup_blocked; fi
/bin/rmdir "$stage/payload" "$stage" || block stage_cleanup_blocked
retained=false
stop_children
finished=true
printf '%s\n' "$result"
