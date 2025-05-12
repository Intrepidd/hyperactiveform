## [Unreleased]

## [0.4.1] - 2025-05-12
- Fixes a bug where if params contained expected falsey values, the form would treat them as nil.
  for instance `form.submit({likes_cat: false})` would set `likes_cat` to nil instead of false.

## [0.4.0] - 2025-01-13
- Add `assigned_attribute_names` method to get the list of attributes that have been assigned during the last call to `assign_form_attributes` or `submit`.
  This is useful in a context where you want to know which attributes have been passed to the form and only act on them rather than the whole attributes hash that might be partly empty (in API calls for example)

## [0.3.0] - 2024-12-22
- Add generators (`rails generate form foo`) ([#2](https://github.com/Intrepidd/hyperactiveform/pull/2) by [@tchiadeu](https://github.com/tchiadeu))

## [0.2.0] - 2024-12-14
- Add callbacks for `assign_form_attributes` and `submit`
- Change behavior of `assign_form_attributes`/`submit` to use the default value or nil if no value is provided, rather than keeping the value from `setup`

## [0.1.0] - 2024-11-30

- Initial release
