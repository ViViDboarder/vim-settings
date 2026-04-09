#! /usr/bin/env fish

function _list_loc
    for d in ~/.local/share/nvim_testing/site/pack/core/opt/*
        set --local loc (cloc --sum-one $d | awk '/SUM/ {print $5}')
        echo "$loc $d"
    end
end

function _pack_plugin_sizes
    echo "Calculating plugin sizes..."
    _list_loc | sort -h | awk '{sum += $1; printf "%8s %s\n", $1, $2} END { printf" Total: %s\n", sum }'
end

_pack_plugin_sizes
