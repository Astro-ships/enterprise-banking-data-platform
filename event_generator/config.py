from pathlib import Path 
import yaml 

config_path=Path(__file__).parent/ "config.yaml"

def load_config() -> dict:
        
        """
    Load the application configuration from config.yaml.

    Returns:
        dict: Parsed configuration.
    """
        with open(config_path,"r",encoding="utf-8") as file:
            config=yaml.safe_load(file)
        return config