import logging
import signal

import uvicorn
from starlette.applications import Starlette
from starlette.config import Config, environ
from starlette.middleware import Middleware
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import HTMLResponse
from starlette.routing import Route

logger = logging.getLogger("uvicorn")


class CustomHeaderMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        response = await call_next(request)
        response.headers["X-DEPLOYMENT-TYPE"] = f"{app.state.config.deployment_type}"
        return response


def startup():
    config = Config()

    try:
        config.deployment_type = f'{environ["DEPLOYMENT_TYPE"]}'.lower()

        if config.deployment_type not in ["blue", "green"]:
            raise ValueError

        app.state.config = config

    except KeyError:
        logger.error("Environment variable DEPLOYMENT_TYPE is not defined")
        signal.raise_signal(signal.SIGINT)

    except ValueError:
        logger.error(
            f"Environment variable DEPLOYMENT_TYPE has value {config.deployment_type} but it should either 'blue' or 'green'"
        )
        signal.raise_signal(signal.SIGINT)


def main(request):
    response = HTMLResponse(content="<html><body><h1>Hello world!</h1></body></html>")
    return response


routes = [Route("/", main)]
middleware = [Middleware(CustomHeaderMiddleware)]
app = Starlette(routes=routes, middleware=middleware, on_startup=[startup])

if __name__ == "__main__":
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
    )
