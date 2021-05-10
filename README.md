# Liti Capital digitalized Shares (LITI) and Wrapped Token (wLITI)

Liti Capital SA is a Swiss investment company that combines blockchain-based solutions, artificial intelligence and investigative capabilities to conduct litigation funding. Liti Capital's assets exist in the form of part ownership of acquired cases. Capitalizing on its network of pre-existing relationships with banks, world-class litigation finance connections and financial institutions, Liti Capital obtains preferential access to the most promising cases and brings them to the general public. 

This repository contains the smart contract codes used to issue digital shares of the company (i.e., LITI tokens) and the wrapped tokens (i.e., wLITI) that represent unregistered equity. Upon completion of the KYC / AML procedure (see terms and conditions www.liticapital.com), Token holders can easily swap one-to-one between wLITI and LITI tokens. 

The LITI smart contract is upgradeable and “owned” (there is an admin in the system) in order to be compliant with current and future regulatory requests. It provides functionalities that, for instance, aim to protect users from losing access to their token. By contrast, the wrapped token smart contract (i.e., wLITI) is not upgradeable and it is not “owned” by Liti Capital. Both contracts are extensions of the ERC20 standard.

Figure 1 shows the general diagram of the Liti Capital ecosystem.

Figure 1 shows the general diagram of the system.	
|![Figure 1](./images/general-diagram.png)|
|:--:|
|*Figure 1*: General diagram of the system|


