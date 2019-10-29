# Python笔记

# 开发环境配置

* pipenv，分项目管理pip包。
* [pyenv](https://docs.pipenv.org/)，分项目管理python版本。

# date和datetime

# 转换

* str to datetime

    ```python
    d = datetime.datetime.strptime(str, '%Y%m%d')
    ```

* unix timestamp to datetime

    ```python
    ts = time.time()
    d = datetime.datetime.fromtimestamp(ts)
    ```

* datetime to str

    ```python
    d.strftime('%Y%m%d')
    ```

# misc

## 添加path

```python
sys.path.append(exePath)
```

## md5

```python
import hashlib
result = hashlib.md5("string")
result.hexdigest()
```
