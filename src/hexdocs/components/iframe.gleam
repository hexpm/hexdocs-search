import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import gleam/pair
import hexdocs/components/attributes
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import lustre/event

const tag_name = "hexdocs-iframe"

pub fn register() {
  lustre.component(init, update, view, [
    component.adopt_styles(True),
    attributes.string("to", UserChangedTo),
    attributes.string("title", UserChangedTitle),
    component.open_shadow_root(True),
  ])
  |> lustre.register(tag_name)
}

pub fn to(to: String) -> Attribute(msg) {
  attribute.attribute("to", to)
}

pub fn title(title: String) -> Attribute(msg) {
  attribute.attribute("title", title)
}

pub fn iframe(attributes: List(Attribute(msg))) {
  element.element(tag_name, attributes, [])
}

type Msg {
  UserChangedTo(to: String)
  UserChangedTitle(title: String)
  IFrameStateChanged(State)
}

type Model {
  Model(to: Option(String), title: String, state: State)
}

type State {
  Loading
  Loaded
}

fn init(_) {
  Model(to: None, title: "", state: Loading)
  |> pair.new(effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(msg)) {
  case msg {
    UserChangedTitle(title) -> #(Model(..model, title:), effect.none())
    IFrameStateChanged(state) -> #(Model(..model, state:), effect.none())
    UserChangedTo(to) -> #(
      Model(..model, to: Some(to), state: Loading),
      effect.none(),
    )
  }
}

fn view(model: Model) {
  case model.to {
    None -> element.none()
    Some(to) -> {
      html.iframe([
        attribute.class(case model.state {
          Loaded -> "mt-4 h-full w-full rounded-lg"
          Loading -> "h-0"
        }),
        attribute.title(model.title),
        event.on("load", decode.success(IFrameStateChanged(Loaded))),
        attribute.src(to),
      ])
    }
  }
}
