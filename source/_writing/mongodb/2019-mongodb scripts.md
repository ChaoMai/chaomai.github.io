# mongodb scripts

```bash
db.createCollection(name, {storageEngine: })

use test_maichao_db;
db.createCollection("test_maichao_cl");
db.test_maichao_cl.createIndex({"clk_key": "hashed"});
sh.enableSharding("test_maichao_db");
sh.shardCollection("test_maichao_db.test_maichao_cl", {"clk_key": "hashed"});

db.test_maichao_cl.insertOne({"clk_key": "1", "data": "123"});
db.test_maichao_cl.insertOne({"clk_key": "2", "data": "124"});
db.test_maichao_cl.insertOne({"clk_key": "3", "data": "125"});

db.dropDatabase();
```
