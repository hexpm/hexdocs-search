import gleam/dict.{type Dict}

pub type Model {
  Model(packages: List(Dict(String, String)))
}

pub fn new() -> Model {
  Model(packages: [])
}

pub fn add_packages(model: Model, packages: List(Dict(String, String))) {
  Model(..model, packages:)
}
