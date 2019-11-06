locals_without_parens = [
  # Ecto
  ## schema
  field: :*,
  belongs_to: :*,
  has_one: :*,
  has_many: :*,
  many_to_many: :*,
  embeds_one: :*,
  embeds_many: :*,
  ## migration
  create: :*,
  create_if_not_exists: :*,
  alter: :*,
  drop: :*,
  drop_if_exists: :*,
  rename: :*,
  add: :*,
  remove: :*,
  modify: :*,
  execute: :*,

  # Phoenix
  ## router
  resources: :*,
  match: :*,
  get: :*,
  post: :*,
  put: :*,
  delete: :*,
  head: :*,
  patch: :*,
  connect: :*,
  options: :*,
  pipe_through: 1,
  forward: :*,
  ## controller
  action_fallback: 1,
  ## socket
  channel: :*,
  transport: :*,
  ## endpoint
  socket: 2,

  # Plug
  plug: :*
]

[
  inputs: [
    "mix.exs",
    ".formatter.exs",
    "{config,lib,priv,test}/**/*.{ex,exs}"
  ],
  locals_without_parens: locals_without_parens
]
