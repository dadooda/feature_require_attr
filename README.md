
Feature::RequireAttr
====================

Simple class attribute validation

Overview
--------

```ruby
require "feature/require_attr"

class Person
  def format
    require_attr :name, not_to_be: :empty
    require_attr :age, to_be_a: Fixnum
    require_attr :jobs, to_respond_to: :each

    ...
  end
end
```

Full documentation is available at [rubydoc.info](http://www.rubydoc.info/github/dadooda/feature_require_attr/Feature/RequireAttr).


Setup
-----

This project is a *sub*. Sub setup example is available [here](https://github.com/dadooda/subs#setup).

For more info on subs, click [here](https://github.com/dadooda/subs).


Cheers!
-------

&mdash; Alex Fortuna, &copy; 2015
