import boto3
import random
import traceback
import time
import os
from datetime import datetime


def get_timestamp(with_decimal: bool=False, force_utc_timestamp: bool=True): 
    epoch = datetime(1970,1,1,0,0,0)
    now = datetime.utcnow()
    if force_utc_timestamp is False:
        now = datetime.now()
    timestamp = (now - epoch).total_seconds()
    if with_decimal:
        return timestamp
    return int(timestamp)


def split_list(lst, chunk_size):
    return [lst[i:i + chunk_size] for i in range(0, len(lst), chunk_size)]


def get_ec2_instances_under_management(client, next_token: str=None, retries: int=0, utc_offset: int=0)->list:
    instances = list()
    
    response = dict()
    try:
        if next_token is None:
            response = client.describe_instances(
                Filters=[
                    {
                        'Name': 'instance-state-code',
                        'Values': [
                            '16',
                        ]
                    },
                    {
                        'Name': 'tag-key',
                        'Values': [
                            'IdleStopperManaged',
                        ]
                    },
                ]
            )
        else:
            response = client.describe_instances(
                Filters=[
                    {
                        'Name': 'instance-state-code',
                        'Values': [
                            '16',
                        ]
                    },
                    {
                        'Name': 'tag-key',
                        'Values': [
                            'IdleStopperManaged',
                        ]
                    },
                ],
                NextToken=next_token
            )
    except:
        print('EXCEPTION: {}'.format(traceback.format_exc()))
        if retries < 4:
            jitter = random.random() * (1+float(retries))
            time.sleep(float(retries) * jitter)
            return get_ec2_instances_under_management(client=client, next_token=next_token, retries=retries+1, utc_offset=utc_offset)
        else:
            return list()
        
    if len(response) > 0:

        if 'Reservations' in response:
            for reservation in response['Reservations']:
                if 'Instances' in reservation:
                    for instance in reservation['Instances']:

                        instance_data = dict()
                        instance_data['InstanceId'] = instance['InstanceId']
                        instance_data['Tags'] = dict()
                        instance_data['LaunchTime'] = int(time.mktime(instance['LaunchTime'].timetuple())) + utc_offset
                        if 'Tags' in instance:
                            for tag_data in instance['Tags']:
                                instance_data['Tags'][tag_data['Key']] = tag_data['Value']
                        instances.append(instance_data)

        if 'NextToken' in response:
            instances += get_ec2_instances_under_management(client=client, next_token=response['NextToken'], utc_offset=utc_offset)

    return instances


def terminate_ec2_instance(client, instance_ids: list):
    try:
        client.terminate_instances(InstanceIds=instance_ids)
    except:
        print('EXCEPTION: {}'.format(traceback.format_exc()))


def handler(event, context): 
    final_status = 'ok'
    now = get_timestamp(with_decimal=False, force_utc_timestamp=True)
    print('now={}'.format(now))
    

    ts = time.time()
    utc_offset = int((datetime.fromtimestamp(ts) - datetime.utcfromtimestamp(ts)).total_seconds())

    current_region = os.getenv('AWS_REGION', 'us-east-1')
    print('current_region={}'.format(current_region))

    instances = get_ec2_instances_under_management(client=boto3.client('ec2', region_name=current_region), utc_offset=utc_offset)
    print('Retrieved {} instances'.format(len(instances)))
    instance_ids_to_terminate = list()
    for instance in instances:
        print('Processing instance {} running since {}'.format(instance['InstanceId'], instance['LaunchTime']))
        runtime = now - instance['LaunchTime']        
        max_age = 7200
        if 'MaxUptime' in instance['Tags']:
            max_age = int(instance['Tags']['MaxUptime'])
        terminate_instance = False
        if runtime > max_age:
            terminate_instance = True
        print('   Configured Max Uptime: : {}'.format(max_age))
        print('   Age                    : {}'.format(runtime))
        print('   Terminate Instance     : {}'.format(terminate_instance))
        if terminate_instance is True:
            instance_ids_to_terminate.append(instance['InstanceId'])
    
    if len(instance_ids_to_terminate) > 0:
        chunks = split_list(lst=instance_ids_to_terminate, chunk_size=10)
        for chunk_of_instance_ids_to_terminate in chunks:
            print('Terminating instance(s): {}'.format(chunk_of_instance_ids_to_terminate))
            terminate_ec2_instance(client=boto3.client('ec2', region_name=current_region), instance_ids=chunk_of_instance_ids_to_terminate)


    return {'status': final_status}


if __name__ == '__main__':
    handler(event=None, context=None)

