#! /usr/bin/env fish

function _list_loc
    for d in ~/.local/share/nvim/lazy/*
        set --local loc (cloc --sum-one $d | awk '/SUM/ {print $5}')
        echo "$loc $d"
    end
end

function _lazy_plugin_sizes
    echo "Calculating plugin sizes..."
    _list_loc | sort -h | awk '{printf "%8s %s\n", $1, $2}'
end

_lazy_plugin_sizes
