Rails App Template
==================

Requirements
------------

1. Have **Ruby** installed. Preferabily `2.1.3`, but works with `2.0.0` also.
2. Have **Rails** installed. This template was created for and tested with version `4.1.6`.

How to use
----------

Assuming that you have Ruby and Rails installed, you'll need to checkout the repo:

```
git clone git@github.com:d3m/d3m-rails-template.git
```

And then run the rails app generator passing the template:

```
rails new app_name -m d3m-rails-template/template.rb
```

It will ask you if you want to install certain gems and install them for you, along with other ones. In the end, it will ask you if you want your database to be created and migrated.
