[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-06-18

    Copyright   : Copyright (C) 2014  Felix C. Stegerman
    Version     : v0.0.2

[]: }}}1

[![Gem Version](https://badge.fury.io/rb/siresta.png)](https://badge.fury.io/rb/siresta)

## Description
[]: {{{1

  siRESTa - declarative REST APIs

  siRESTa is a DSL for declarative REST APIs.  It can generate a ruby
  API (w/ sinatra [1]) and Client (w/ excon [2]) for you, based on a
  YAML file.  Processing requests is done using a monad.

  More documentation is underway.  For now, see `example/` and
  `features/`.

  ...

[]: }}}1

## Examples
[]: {{{1

  ```yaml
  name:     FooBarBaz
  version:  v1
  request_formats:  [json, xml]
  response_formats: [json, xml]
  api:
  - resource: foos
    contains:
    - desc: Gets foos
      get:  get_foos
    - post: create_foo
    - resource: :foo_id
      contains:
      - desc:   Get a foo
        get:    get_foo
      - put:    create_foo
      - delete: delete_foo
      - resource: bars
        contains:
        - get: get_bars
        # ...
  - resource: baz
    contains:
    - get: get_baz
    # ...
  ```

  ```ruby
  require 'siresta'
  API = Siresta.api file: 'config/api.yml'
  class API
    data :foos, []

    handle :get_foos do |m, h, p, b|
      m.get_data(:foos) { |foos| m.ok foos }
    end

    # ...
  end
  API.run!
  ```

  ```
  GET     /foos
  POST    /foos
  GET     /foos/:foo_id
  PUT     /foos/:foo_id
  DELETE  /foos/:foo_id
  GET     /foos/:foo_id/bars
  GET     /baz
  ...
  ```

  ```ruby
  require 'siresta'
  Client = Siresta.client
  c = Client.new 'http://localhost:4567'

  c.foos.get
  c.foos.post headers: { 'Content-Type' => 'foo/bar' }
  c.foos[some_foo_id].get query: { foo: 'bar' }
  c.foos[some_foo_id].put
  c.foos[some_foo_id].delete
  c.foos[some_foo_id].bars.get
  c.baz.get
  ```

  ```ruby
  require 'siresta'
  Siresta.routes
  # => [["GET",     "/foos",              "Gets foos" ],
  #     ["POST",    "/foos",              nil         ],
  #     ["GET",     "/foos/:foo_id",      "Get a foo" ],
  #     ["PUT",     "/foos/:foo_id",      nil         ],
  #     ["DELETE",  "/foos/:foo_id",      nil         ],
  #     ["GET",     "/foos/:foo_id/bars", nil         ],
  #     ["GET",     "/baz",               nil         ]]
  ```

[]: }}}1

## Specs & Docs

```bash
$ rake cuke
$ rake docs
```

## TODO

  * finish monad, api
  * specs
  * docs
  * authorization?
  * authentication?

## License

  LGPLv3+ [3].

## References

  [1] Sinatra
  --- http://www.sinatrarb.com

  [2] Excon
  --- https://github.com/excon/excon

  [3] GNU Lesser General Public License, version 3
  --- http://www.gnu.org/licenses/lgpl-3.0.html

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
