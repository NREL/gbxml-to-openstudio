import json
import os
import platform
import sys

from dotenv import load_dotenv

load_dotenv()
os_version = os.getenv('OS_VERSION')

if platform.system() == 'Windows':
    energyplus_dir = f'C:\\openstudio-{os_version}\\EnergyPlus'
elif platform.system() == 'Darwin':
    energyplus_dir = f'/Applications/OpenStudio-${os_version}'
else:
    print('Unsupported OS')
    sys.exit(1)

sys.path.insert(0, str(energyplus_dir))
from pyenergyplus.api import EnergyPlusAPI

api = EnergyPlusAPI()
state = api.state_manager.new_state()

error_types = [
  'Continue',
  'Info',
  'Warning',
  'Severe',
  'Fatal',
]

result = {
  'success': False,
  'output': {
    'Continue': [],
    'Info': [],
    'Warning': [],
    'Severe': [],
    'Fatal': []
  }
}


def error_handler(severity: int, message: bytes) -> None:
    output = message.decode('utf-8')
    if len(output):
        result['output'][error_types[severity]].append(message.decode('utf-8'))


api.functional.callback_error(state, error_handler)

root = os.path.join(os.path.dirname(__file__), '../..')
return_value = api.runtime.run_energyplus(
    state, [
        '-d', os.path.join(root, 'workflows/regression-tests', os_version, 'Office.xml/run'),
        '-a',
        '-w', os.path.join(root, 'weather/USA_CO_Denver.Intl.AP.725650_TMY3.epw'),
        os.path.join(root, 'workflows/regression-tests', os_version, 'Office.xml/run/in.idf')
    ]
)

result['success'] = return_value == 0

with open(os.path.join(root, 'workflows/regression-tests', os_version, 'Office.xml/result.json'), 'w', encoding='utf-8') as f:
    json.dump(result, f, ensure_ascii=False, indent=2)

# print("EnergyPlus Version: " + str(api.functional.ep_version()))

sys.exit(return_value)
