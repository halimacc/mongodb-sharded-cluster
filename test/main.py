from pymongo import MongoClient
from timeit import Timer
from functools import partial

# ref: http://stackoverflow.com/questions/8437245/get-execution-time-function-in-python
def get_execution_time(function, numberOfExecTime, *args, **kwargs):
    """Return the execution time of a function in seconds."""
    return round(Timer(partial(function, *args, **kwargs))
                 .timeit(numberOfExecTime), 5)

# parameters:
#   @collection: the target collection
#   @workload: workload function to test
def get_throughput(collection, workload):
    operations = [0]
    time = get_execution_time(workload, 1, collection, operations)
    return operations[0] / time



client = MongoClient('mongodb://23.99.108.221:27017/')
usertable1 = client['ycsb']['usertable']
usertable2 = client['ycsbhashed']['usertable']

keys = usertable1.find()
print(keys.count())

def workload_test(collection, operations):
    operations[0] = 10
    for i in range(operations[0]):
        collection.insert({'_id':'test' + str(i)})

print(get_throughput(usertable1, workload_test))
print(get_throughput(usertable2, workload_test))
