let upstream =
      https://github.com/kritzcreek/vessel-package-set/releases/download/mo-0.4.3-20200916/package-set.dhall sha256:3e1d8d20e35550bc711ae94f94da8b0091e3a3094f91874ff62686c070478dd7

let overrides =
      [ { name = "base"
        , version = "92046a6a4f6dfd8412f2b21252ad17501fee14f8"
        , repo = "https://github.com/dfinity/motoko-base"
        , dependencies = [] : List Text
        }
      ]

in  upstream # overrides
