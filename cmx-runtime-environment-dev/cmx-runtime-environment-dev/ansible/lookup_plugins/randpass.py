from __future__ import (absolute_import, division, print_function)
from ansible.utils.display import Display
from ansible.plugins.lookup import LookupBase
from ansible.errors import AnsibleError, AnsibleParserError
import string
import secrets
__metaclass__ = type

DOCUMENTATION = """
        lookup: randpass
        author: Shaun Hines <shaun@codametrix.com>
        version_added: "2.10"
        short_description: generate alphanumeric password of specified length
        description:
            - This lookup plugin generates a alphanumeric password of a specified length
              with options to specify number of uppercase, lowercase and digits
        options:
          _terms:
            description: range aka length of password (min 8)
            type: int
            required: True
          uppercase:
            description: number of uppercase characters
            type: int
            default: 2
          lowercase:
            description: number of lowercase characters
            type: int
            default: 2
          digits:
            description: number of digits
            type: int
            default: 2
        notes:
          - this exists because the password lookup plugin does not allow
            max/min values per character type
"""

display = Display()


class LookupModule(LookupBase):

    def run(self, terms, variables=None, **kwargs):

        self.set_options(var_options=variables, direct=kwargs)

        ret = []
        for term in terms:

            term_int = int(term)

            if term_int < 8:
                raise AnsibleError("term must be >= 8")

            display.vvvv("generating password of length %s" % term)

            try:
                alphabet = string.ascii_letters + string.digits
                display.vvvv("raw password %s" % alphabet)

                uppercase = int(self.get_option('uppercase'))
                if uppercase > term_int:
                    raise AnsibleError("number of uppercase characters > %s" % term)
                lowercase = int(self.get_option('lowercase'))
                if lowercase > term_int:
                    raise AnsibleError("number of lowercase characters > %s" % term)
                digits = int(self.get_option('digits'))
                if digits > term_int:
                    raise AnsibleError("number of digits characters > %s" % term)

                sum_upper_lower_digits = uppercase + lowercase + digits
                if sum_upper_lower_digits > term_int:
                    raise AnsibleError(
                        "sum of uppercase lowercase and digits > %s" %
                        term)

                while True:
                    password = ''.join(secrets.choice(alphabet) for i in range(term_int))
                    if (sum(c.islower() for c in password) >= lowercase
                            and sum(c.isupper() for c in password) >= uppercase
                            and sum(c.isdigit() for c in password) >= digits):
                        break
                ret.append(password)
            except AnsibleParserError:
                raise AnsibleError("could not locate file in lookup: %s" % term)

        return ret
