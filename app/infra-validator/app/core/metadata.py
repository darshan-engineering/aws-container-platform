import os
import requests

def get_ecs_metadata():
    metadata_uri = os.getenv("ECS_CONTAINER_METADATA_URI_V4")

    if not metadata_uri:
        return {
            "running_in_ecs": False
        }

    try:
        response = requests.get(
            f"{metadata_uri}/task",
            timeout=5
        )

        response.raise_for_status()

        task = response.json()

        return {
            "running_in_ecs": True,
            "task_arn": task.get("TaskARN"),
            "family": task.get("Family"),
            "revision": task.get("Revision"),
            "availability_zone": task.get("AvailabilityZone")
        }

    except Exception as e:
        return {
            "running_in_ecs": False,
            "error": str(e)
        }

