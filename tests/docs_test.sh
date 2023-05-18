#!/bin/sh

set -eu

docs="docs"
stardoc_outputs="tools/stardoc"

rc=0
for filename in "${stardoc_outputs}/"*.md; do
	diff -uN "${docs}/${filename#"${stardoc_outputs}"}" "${filename}" || rc=1
done
for filename in "${docs}/"*.md; do
	if grep -q -- 'Generated with Stardoc' "${filename}"; then
		stardoc_out="${stardoc_outputs}/${filename#"${docs}"}"
		if [ ! -f "${stardoc_out}" ]; then
			diff -uN "${filename}" "${stardoc_out}"
			rc=1
		fi
	fi
done

exit $rc
