return {
    "gyl30/translate",
    keys = {
        { "<localleader>t", module = { "n" }, function() require("translate").translateN() end },
        { "<localleader>t", module = { "v" }, function() require("translate").translateV() end },
    }
}
