# Canaid

Canaid is an authorization aid / permission helper that allows you to define various permissions, and makes it easy for you to use them inside Rails application. There are already many solutions out there for Rails authorization. Canaid assumes the following:

* each permission/authorization is evaluated against 2 objects: user object (=the user that tries to access the resource) and an object itself (=resource);
* in case that permission isn't evaluated against the access object/resource, it's called a "generic" permission and is evaluated only against the user.
* permissions are an application-domain (cross-cutting) concern, and should therefore be isolated in a shared codespace;
* modular/overloaded permissions should be supported.

## Requirements

* [rails](https://github.com/rails/rails) >= 4
* [devise](https://github.com/plataformatec/devise) >= 3.4.1

## Install

Put the Gem inside your `Gemfile`:

```ruby
gem 'canaid', git: 'https://github.com/biosistemika/canaid', branch: 'master'
```

Then run `bundle install`.

## Usage

### Registering permissions

You can register new permission/s by writing the following code in Ruby files inside `app/permissions/**/*.rb` in your Rails application:

**A)**

```ruby
# app/permissions/permissions.rb
# can <permission_name>, <object_class>, <priority?>, { <function(user, obj)> }
Canaid::Permissions.register do
  can :view_team_projects, Team, 10 do |user, team|
    user.logged_in? &&
    team.users.include?(user)
  end

  can :update_project, Project do |user, project|
    user.logged_in? &&
    project.users.include?(user)
  end
end
```

The argument `10` is a priority that dictates the order in which the permission checks are evaluated if multiple permissions are registered for the same name. **The argument is optional and can be avoided.** This is reserved for future.

> **Important!** Each permission also has an object class specified alongside, to which the passed object itself is checked when permission is queried.

This will result in the following helper methods to be available to all controllers & views:

```ruby
can_view_team_projects?(team)
can_view_team_projects?(user, team)

can_update_project?(project)
can_update_project?(user, project)
```

> **Note!** For where user is not provided, Devise's `current_user` variable is automatically used.

**B)**

Alternatively, to define multiple permissions for the same object class:

```ruby
# app/permissions/permissions.rb
# can <permission_name>, <priority?>, { <function(user, obj)> }
Canaid::Permissions.register_for(Team) do
  can :create_new_project, 10 do |user, team|
    user.logged_in? &&
    team.users.include?(user) &&
    user_is_team_admin?(user, team)
  end

  can :view_team_projects do |user, team|
    user.logged_in? &&
    team.users.include?(user)
  end
end
```

This will result in the following helper methods to be available to all controllers & views:

```ruby
can_create_new_project?(team)
can_create_new_project?(user, team)

can_view_team_projects?(team)
can_view_team_projects?(user, team)
```

**C)**

Lastly, you can define generic permissions that don't have a related object class:

```ruby
# app/permissions/permissions.rb
# can <permission_name>, <priority?>, { <function(user)> }
Canaid::Permissions.register_generic do
  can :invite_users, 10 do |user|
    user.logged_in? &&
    user.admin?
  end

  can :delete_users do |user|
    user.logged_in? &&
    user.admin?
  end
end
```

This will result in the following helper methods to be available to all controllers & views:

```ruby
can_invite_users?
can_invite_users?(user)

can_delete_users?
can_delete_users?(user)
```

### Multiple registrations

You can also register the same permission multiple times (e.g. from within different Rails engines). All permissions of the same name are then evaluated in the order specified by `priority` argument (lower number means higher priority), and then `&&` is performed on all of them (so, to achieve a `true` result of a permission check, all registered permissions need to evaluate `true`).

So, suppose we had the following registration:

```ruby
Canaid::Permissions.register do
  can :update_project, Project, 10 do |user, project|
    <perm_1_eval>
  end

  can :update_project, Project, 7 do |user, project|
    <perm_2_eval>
  end
end
```

When calling `can_update_project?`, this would eval to the following:
```
<perm_2_eval> && <perm_1_eval>
```

### Custom permissions paths

To change the locations/paths of the permission files, define an initializer inside your application (e.g. `config/initializers/canaid.rb`) with the following code:

```ruby
Canaid.configure do |config|
  config.permissions_paths = [<your_paths_to_permission_files>]
end
```

This way, it's also easy to specify multiple paths by using e.g. `<<` operator.

> **Important!** All the files that match this provided path are then `require`-d during the initialization of Rails server, so be careful when you change this to something different.

## Copyright

This Gem is licensed under the [MIT license](MIT-LICENSE).