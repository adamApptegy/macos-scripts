#!/bin/zsh

FMMstatus=$(nvram -x -p | grep fmm-mobileme-token-FMM)
if [[ $FMMstatus ]]; then echo "true"; else echo "false"; fi