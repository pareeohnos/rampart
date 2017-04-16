[![Build Status](https://travis-ci.org/pareeohnos/rampart.svg?branch=master)](https://travis-ci.org/pareeohnos/rampart)

Full documentation available [here](https://hexdocs.pm/rampart/1.0.0/Rampart.html)

# Rampart

Rampart is a simple yet flexible authorization library, to help you manage
user permissions within your application.

For those of you familiar with Ruby on Rails, and in particular the gem
`Pundit`, you will notice very big similarties, as Rampart has taken
most of its inspiration from this gem.

## Installation

To install rampart, simply add it as a dependency to your application.

```elixir
defp deps do
  [{ :rampart, "~> 1.0.0 }]
end
```

You should also add it into your applications list as well to ensure that
Rampart is started with your own application.

```elixir
def application do
  [applications: [:rampart]]
end
```


## Policies

Rampart uses Policy modules to define what a user can and cannot do within
your application. These are simple modules with nothing special in them.
Lets take a look at a basic example:

```elixir
defmodule MyApp.PostPolicy do
  use Rampart.Policy

  alias MyApp.Post

  def index?(current_user, Post), do: true
  def show?(current_user, %Post{} = post) do
    current_user.id == post.user_id
  end

end
```

As you can see, this is just like any other elixir module, but the important
line here is the `use Rampart.Policy`. If you do not add this, then Rampart
will not be able to detect your policy when the application starts.

Each function that you define in this module should match the name of the
controller action that it relates to. In the example above, your controller
may look like this:

```elixir
defmodule MyApp.PostController do
  use MyApp.Web, :controller
  alias MyApp.Post

  def index(conn, _params) do
    authorize!(Post)
  end

  def show(conn, params) do
    post = Repo.get(Post, params[:id])
    authorize!(post)
  end

end
```

We'll cover it later, but as you can see here, the only thing you have to
do is call the `authorize!/1` function, and Rampart will handle the rest.
Your `index/2` action will call the `index?/2` action in your policy, and
the `show/2` action will call the `show?/2` action in your policy.

You are free to add any logic into your policies as you wish, there are no
restrictions, however it must return a boolean value. Also keep in mind,
that an application may call the functions of your policies many times, so
it is best to keep them as simple as you can so as not to slow down your
application too much.


## Authorizing the request

We very briefly saw how to authorize a request in the example above, but
there are a few more details that we need to look at.

The first thing to note is that your controller must `use` the 
`Rampart.Controller` module. If you wish, you can do so in each of your
controllers, but if you're using a framework such as Phoenix, then it is
far simpler to use it in your `web.ex` instead

```elixir
defmodule MyApp.Web do
  ...
  
  def controller do
    quote do
      ...
        use Rampart.Controller
      ...
    end
  end

  ...
end
```

Once this has been done, you will have access to the functions required
to perform your authorization. `authorize!/1` that we saw above is the
one you will be using the most. It expects a single argument which is 
the resource being authorized.

We say `resource` but this may in fact be a module. Not all actions
being authorized may be a single data item, and instead may be a
collection, so in this instance we can simply pass the module. For
example (as above), if we have a `Post` module, authorize the index
action, we would call

```elixir
authorize!(Post)
```

For an action where there is a singular resource, such as the `show`
action, we can instead pass the actual resource to the `authorize!/1`
function.


#### Specify action

In some cases, you may not want Rampart to infer the action name, 
and instead specify your own. For this, there is the `authorize!/2`
function, where the second argument is the policy action you wish
to use. Using the `Post` example again, if we had an edit action,
as well as a `close` action, they may share the same permission.

```elixir
defmodule MyApp.PostController do
  use MyApp.Web, :controller
  alias MyApp.Post

  def edit(conn, params) do
    post = Repo.get(Post, params[:id])
    authorize!(post)
  end

  def close(conn, params) do
    post = Repo.get(Post, params[:id])
    authorize!(post, :edit?)
  end

end
```

In your policy, you would not be required to implement the 
`close?/2` function as you have specified which function to
use. Of course, you could also implement the `close?/2` function
and have it call the `edit?/2` function, but that is up to 
you.


#### Plug

One thing to note about the authorize functions, is that they
assume your controller contains a `plug` function. If you're
working with Phoenix, then this is the case and there's nothing
you need to do, but if not then you may need to adjust your 
applications configuration to be able to use Rampart.

If you would rather specify your authorization as a plug than
use the convenience functions, then you are free to do so. You
will have to specify the resource, but you will also have to
specify the action:

```elixir
plug Rampart.Authorize, resource: Post, action: :index?

post = Repo.get(Post, params[:id])
plug Rampart.Authorize, resource: port, action: :index?
```

It's a little more verbose, but if you prefer to be explicit
about every detail, this may be a preferred option. It's 
entirely up to you however.


## Using in views and templates

To use Rampart in your views and templates, as with the controller
you will need to make it `use` it in your views. Once again with
Phoenix, you can do this in your `web.ex` file.

```elixir
defmodule MyApp.Web do
  ...
  
  def view do
    quote do
      ...
        use Rampart.View
      ...
    end
  end

  ...
end
```

Your views and templates will now have access to the function 
`has_permission?/3`. This can be used to quickly determine if
the supplied user has the appropriate permission to perform 
the specified action on the specified resource.

```elixir
<div class="navigation">
  <%= if has_permission?(@conn.assigns.current_user, :index?, Post) do %>
    ...
  <% end %>
</div>
```

Here you must supply the current user, the action, and the resource,
as Rampart will not have access to the `conn` and cannot gather
this information itself.

## Ensuring authorization

During development, you may wish to ensure that authorization has
been performed on all actions. For this, Rampart provides a second
plug called the `enforcer` which will do just this. To use it, 
simply place it in the pipeline of your router.

```elixir
defmodule MyApp.Router do

  ...

  pipeline :browser do
    ...
    plug Rampart.Enforcer
  end

end
```

If a controller does not perform an authorization and you are using
this plug, then the request will result in a `Rampart.Exceptions.AuthorizationNotPerformed`
exception being raised.

Note that this is not recommended for production, however Rampart
will not prevent you from doing so. 

## Advanced

Rampart has a few other features which may come in handy.

#### Dynamically setting policy

When Rampart attempts to determine the policy of the resource
it is given, it will check to see if that resource's module
implements either of the `policy/0` or `policy/1` functions.

- `policy/0`

The `policy/0` function simply returns the desired policy module
to use for that resource.

```elixir
defmodule Admin do
  use MyApp, :model

  ...

  def policy, do: MyApp.UserPolicy
end
```

Any attempt to authorize an Admin will result in Rampart using
the `UserPolicy` instead of inferring the `AdminPolicy`.

- `policy/1`

The `policy/1` function is identical to `policy/0`, however
it will be supplied with the resource that is being authorized.
Again, you must return the policy module to use.


#### Pre-authorization

Rampart provides a pre-authorization mechanism, that can be used
to simplify your policies. In some situations, you may find that
you have a number of actions that are only available to certain
users, but one or two are available to more. Instead of having 
to check this user type in every single policy function, you
can implement the function `should_proceed?/2` in your policy
instead.

This function will be supplied with the same two arguments as 
all of the other policy functions (user and resource), and it
is also expected to return a boolean value. Returning false will
also result in a forbidden exception being raised, however this
function will be called before the main authorization function.

```elixir
defmodule MyApp.UserPolicy do
  use Rampart.Policy

  def should_proceed?(user, _resource, action) do
    user.is_admin? || action in [:index?]
  end

  def index?(_user, _resource), do: true

  def edit?(_user, _resource), do: true
  def update?(_user, _resource), do: true

end
```

In this example the `edit?/2` and `update?/2` functions are only
available for administrators, however as you can see, we don't 
need to test that the user is an administrator in every function.
Instead, the `should_proceed?/3` function does this for us.

Here, we return `true` if the user is an admin, or the action
being called is the `index?/2` function. Therefore, every action
that isn't `index?/2` can only be performed by an administrator.


## Configuration

When performation authorization from within a controller, Rampart
will check the `conn` for the `:current_user` key. This will work
for most authentication libraries, however if you are using a 
library that uses something else, you can configure Rampart to 
look for something else. In your config file, simply add the
following:

```elixir
config :rampart,
  current_user: :logged_in_user
```


## Notes

Rampart is currenty very new, and as such it may be incomplete. I have
tried to think of most use cases, but there are probably many more than
I've missed. That's where you come in.

If there is a feature you would love for Rampart to have, then open an
issue and we can discuss it. If there's a bug you've come across, open
an issue.

## Contributing

If you think Rampart is lacking in features, has a bug, or there's 
something you simply don't like, then I welcome anyone to raise the
issue or create a pull request. 

For new features, please open an issue before submitting any pull 
requests, as this will allow for discussion with the community as
to whether such features should be added.

For bugs, feel free to raise an issue, or simply a pull request 
if you're certain it is actually a bug.

