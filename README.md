JSONPretty
==========

JSON pretty print shell, is based on https://github.com/dominictarr/JSON.sh .

### Example:

``` bash
echo '{"status":200,"data":[{"id":1000,"name":"John"},{"id":1004,"name":"Tom"}]}'|./JSONPretty.sh
```

### Results:
```javascript
{
        "status":200,
        "data":[{
                "id":1000,
                "name":"John"
        },{
                "id":1004,
                "name":"Tom"
        }]
}
```
## LICENSE

This software is available under the following licenses:

  * MIT
  * Apache 2

