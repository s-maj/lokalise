import asyncio
import logging
import os

import httpx

logging.basicConfig(
    format="%(asctime)s.%(msecs)03d %(levelname)-8s %(message)s",
    level=logging.INFO,
    datefmt="%Y-%m-%d %H:%M:%S",
)

app_url = os.environ["APP_URL"]


async def producer(client, queue):
    while True:
        r = client.get("app_url")
        await queue.put(r)
        await asyncio.sleep(0.1)


async def consumer(queue):
    while True:
        r = await queue.get()
        r = await r
        logging.info(f"{r.url}: {r.status_code}, {r.headers['x-deployment-type']}")


async def main():
    queue = asyncio.Queue(10)
    async with httpx.AsyncClient() as client:
        await asyncio.gather(producer(client, queue), consumer(queue))


asyncio.run(main())
