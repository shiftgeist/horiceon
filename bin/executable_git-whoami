#!/bin/sh

set -e

get_name() {
	git config --show-origin user.name
}

get_email() {
	git config user.email
}

get_gpg() {
	git config user.signingkey
}

echo "$(get_name) <$(get_email)> $(get_gpg)"
