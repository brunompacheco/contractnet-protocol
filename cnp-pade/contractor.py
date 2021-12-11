from typing import List

from pade.misc.utility import call_later, display_message
from pade.core.agent import Agent
from pade.acl.aid import AID
from pade.acl.messages import ACLMessage
from pade.behaviours.protocols import FipaContractNetProtocol


class BehaviourContractor(FipaContractNetProtocol):
    def __init__(self, agent, message: ACLMessage):
        super().__init__(agent, message=message, is_initiator=True)

        self.id = message.content

    def display(self, msg: str):
        return display_message(self.agent.aid.name, f"[contract '{self.id}'] " + msg)

    def handle_all_proposes(self, proposes):
        super().handle_all_proposes(proposes)

        prices = [float(p.content) for p in proposes]

        # selects proposal based on price
        best_proposal = proposes[min(range(len(prices)), key=prices.__getitem__)]

        self.display(f"Best proposal (out of {len(proposes)}) from {best_proposal.sender.name} with price {best_proposal.content}")

        accept_msg = ACLMessage(ACLMessage.ACCEPT_PROPOSAL)
        accept_msg.set_protocol(ACLMessage.FIPA_CONTRACT_NET_PROTOCOL)
        accept_msg.add_receiver(best_proposal.sender)
        accept_msg.set_content(self.id)
        self.agent.send(accept_msg)

        refuse_msg = ACLMessage(ACLMessage.REJECT_PROPOSAL)
        refuse_msg.set_protocol(ACLMessage.FIPA_CONTRACT_NET_PROTOCOL)
        refuse_msg.set_content(self.id)
        for proposal in proposes:
            if proposal != best_proposal:
                refuse_msg.add_receiver(proposal.sender)
        self.agent.send(refuse_msg)

    def handle_inform(self, message):
        super().handle_inform(message)

        if message.content == 'DONE':
            self.display(f'Agent {message.sender.name} finished the task')

class AgentContractor(Agent):
    def __init__(self, aid, participants: List[str], i=1, debug=False):
        super().__init__(aid, debug=debug)

        self.participants = participants

        contract_id = self.aid.port * 10
        for _ in range(i):
            call_later(8.0, self.launch_contract, contract_id)
            contract_id += 1

    def launch_contract(self, contract_id: int):
        contract_message = ACLMessage(ACLMessage.CFP)
        contract_message.set_protocol(ACLMessage.FIPA_CONTRACT_NET_PROTOCOL)
        contract_message.set_content(contract_id)
        for participant in self.participants:
            contract_message.add_receiver(AID(name=participant))

        contract_behaviour = BehaviourContractor(self, message=contract_message)
        self.behaviours.append(contract_behaviour)

        display_message(self.aid.name, 'CNP started')
        contract_behaviour.on_start()
