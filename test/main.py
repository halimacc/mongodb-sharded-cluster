from pymongo import MongoClient

client = MongoClient('mongodb://23.99.108.221:27017/')
db = client['ycsb']
usertable = db['usertable']
print(usertable.find().count())

async def do_insert():
    