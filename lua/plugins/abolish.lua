return {
    "tpope/vim-abolish",
    cmd = {
        "Abolish",
        "Subvert",
        "S",
    },
    keys = {
        { "crs", mode = { "n", "x" }, desc = "coerce to snake_case" },
        { "crc", mode = { "n", "x" }, desc = "coerce to camelCase" },
        { "crm", mode = { "n", "x" }, desc = "coerce to MixedCase" },
        { "cru", mode = { "n", "x" }, desc = "coerce to UPPER_CASE" },
        { "cr-", mode = { "n", "x" }, desc = "coerce to dash-case" },
        { "cr.", mode = { "n", "x" }, desc = "coerce to dot.case" },
        { "cr ", mode = { "n", "x" }, desc = "coerce to space case" },
        { "crt", mode = { "n", "x" }, desc = "coerce to Title Case" },
    },
}
