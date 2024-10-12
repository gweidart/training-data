# labeler.py
import os
import re
from patterns import patterns

def label_vulnerabilities(token_content, patterns):
    """
    Applies vulnerability patterns to the token content and returns labels.
    
    Args:
        token_content (str): The tokenized Solidity code content.
        patterns (dict): Dictionary of vulnerability patterns to check for.

    Returns:
        list: A list of detected vulnerability labels.
    """
    labels = []
    matches = {}

    # Check for matches in the token content for each pattern
    for vuln_name, pattern in patterns.items():
        if pattern.search(token_content):
            matches[vuln_name] = True
        else:
            matches[vuln_name] = False

    # Conditional logic for labeling vulnerabilities

    # Timestamp Dependency
    ts_invocation = bool(matches.get('TSInvocation'))
    ts_contaminate = bool(matches.get('TSContaminate'))
    ts_random = bool(matches.get('TSRandom'))

    if ts_invocation or (ts_contaminate and ts_random):
        labels.append('timestamp_dependency')
    else:
        labels.append(0)

    # Block Number Dependency
    bn_invocation = bool(matches.get('BNInvocation'))
    bn_contaminate = bool(matches.get('BNContaminate'))

    if bn_invocation and bn_contaminate:
        labels.append('block_number_dependency')
    else:
        labels.append(0)

    # Ether Strict Equality Vulnerability
    ed_invocation = bool(matches.get('EDInvocation'))
    ed_contaminate = bool(matches.get('EDContaminate'))

    if ed_invocation and ed_contaminate:
        labels.append('ether_strict_equality_vulnerability')
    else:
        labels.append(0)

    # Integer Overflow Vulnerability
    of_stack_truncate = bool(matches.get('OFStackTruncate'))
    safe_math_usage = bool(matches.get('SafeMathUsage'))

    if of_stack_truncate and not safe_math_usage:
        labels.append('integer_overflow_vulnerability')
    else:
        labels.append(0)

    # Unchecked External Call Vulnerability
    external_call = bool(matches.get('ExternalCall'))
    exception_consistency = bool(matches.get('ExceptionConsistency'))
    return_condition = bool(matches.get('ReturnCondition'))

    if external_call and exception_consistency and not return_condition:
        labels.append('unchecked_external_call_vulnerability')
    else:
        labels.append(0)

    # Ether Frozen Vulnerability
    dg_invocation = bool(matches.get('DGInvocation'))
    fe_transfer = bool(matches.get('FETransfer'))

    if dg_invocation and not fe_transfer:
        labels.append('ether_frozen_vulnerability')
    else:
        labels.append(0)

    # Delegatecall Vulnerability
    dg_call_constraint = bool(matches.get('DGCallConstraint'))
    dg_parameter = bool(matches.get('DGParameter'))

    if dg_invocation and not dg_call_constraint and dg_parameter:
        labels.append('delegatecall_vulnerability')
    else:
        labels.append(0)

    # Reentrancy
    if matches.get('CALLValueInvocation'):
        if matches.get('RepeatedCallValue'):
            labels.append('reentrancy')
        else:
            labels.append(0)
    else:
        labels.append(0)

    # Access Control Violation
    access_control_violation = bool(matches.get('access_control_violation'))
    missing_modifier = bool(matches.get('MissingModifier'))

    if access_control_violation and missing_modifier:
        labels.append('access_control_violation')
    else:
        labels.append(0)

    # Incorrect Storage Initialization
    incorrect_storage_initialization = bool(matches.get('IncorrectStorageInitialization'))
    constructor_initialization = bool(matches.get('ConstructorInitialization'))

    if incorrect_storage_initialization and not constructor_initialization:
        labels.append('incorrect_storage_initialization')
    else:
        labels.append(0)

    # DDoS Vulnerability
    ddos_vulnerability = bool(matches.get('DDoSVulnerability'))
    gas_limit_check = bool(matches.get('GasLimitCheck'))
    external_call_in_loop = bool(matches.get('ExternalCallInLoop'))

    if ddos_vulnerability and not gas_limit_check and external_call_in_loop:
        labels.append('ddos_vulnerability')
    else:
        labels.append(0)

    # Transaction Ordering Dependence
    transaction_ordering_dependence = bool(matches.get('TransactionOrderingDependence'))
    randomness_source = bool(matches.get('RandomnessSource'))

    if transaction_ordering_dependence and randomness_source:
        labels.append('transaction_ordering_dependence')
    else:
        labels.append(0)

    # Lack of Randomness
    lack_of_randomness = bool(matches.get('LackOfRandomness'))
    secure_randomness = bool(matches.get('SecureRandomness'))

    if lack_of_randomness and not secure_randomness:
        labels.append('lack_of_randomness')
    else:
        labels.append(0)

    # ERC20 API Violation
    erc20_api_violation = bool(matches.get('ERC20APIViolation'))
    event_emission = bool(matches.get('EventEmission'))

    if erc20_api_violation and not event_emission:
        labels.append('erc20_api_violation')
    else:
        labels.append(0)

    # Signatures Replay
    signatures_replay = bool(matches.get('SignaturesReplay'))
    nonce_usage = bool(matches.get('NonceUsage'))
    signature_verification = bool(matches.get('SignatureVerification'))

    if signatures_replay and not nonce_usage and not signature_verification:
        labels.append('signatures_replay')
    else:
        labels.append(0)

    return labels
