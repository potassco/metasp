"""
The metasp project.
"""

import logging
import os
import sys
import yaml

from .utils.logging import get_logger

log = get_logger(__name__)


def get_configuration() -> dict:
    """
    Load the configuration from the metasp.yml file.
    Returns:
        dict: The configuration dictionary loaded from the YAML file.
    """
    # Get the configuration file to know the available commands
    config_path = os.path.join(os.getcwd(), "metasp.yml")
    if not os.path.isfile(config_path):
        log.error(f"Configuration file not found: {config_path}")
        raise FileNotFoundError(f"Configuration file not found: {config_path}")

    with open(config_path, "r") as config_file:
        try:
            config = yaml.safe_load(config_file)
            log.info(f"Loaded configuration from {config_path}")
            return config
        except yaml.YAMLError as e:
            log.error(f"Error parsing configuration file: {e}")
            raise e
