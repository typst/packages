#import "@preview/simple-cheatsheet:0.1.0": cheatsheet, container

#show: cheatsheet.with(
  info: (
    title: "Cybersecurity Fundamentals",
    authors: ("John Doe", "Jane Doe"),
  ),
)

= Core Principles
#container[
  == CIA Triad
  The three pillars of information security:
  - *Confidentiality*: Sensitive data must be protected from unauthorised read access
  - *Integrity*: Data and systems must be protected from unauthorised modification
  - *Availability*: Information must be accessible when needed by authorised users
  
  == Key Terminology
  - *Vulnerability*: A defect (bug or flaw) in a system that an attacker can exploit
  - *Threat*: A possible danger that might exploit a vulnerability
    - _Intentional_: Attacker actively developing an exploit
    - _Accidental_: Environmental factors (e.g., server room fire)
  - *Threat Agent*: An individual or entity carrying out an attack
  - *Threat Action*: The actual procedure used to execute an attack
  - *Exploit*: A concrete attack that leverages a vulnerability (e.g., malware program)
  - *Asset*: Anything of value to an organisation (hardware, software, data, etc.)
  - *Risk*: The criticality of a threat or vulnerability
    - Formula: $"Risk" = "Probability" times "Impact"$
  - *Countermeasure*: Any action, device, process, or technique that reduces risk

  == Malware Classification
  - *Malware*: Malicious software designed to disrupt operations, steal information, or gain unauthorised access
  - *Virus*: Spreads by inserting copies into executable programs or documents (requires a host). Typically needs user interaction to propagate
  - *Worm*: Self-replicating malware that spreads autonomously without requiring a host program. Scans networks for vulnerable systems
  - *Trojan*: Disguises itself as legitimate software but contains malicious code. Does not self-replicate
  - *Drive-by Download*: Exploits browser or plugin vulnerabilities to automatically execute malicious code from compromised websites
  - *Ransomware*: Encrypts victim's data and demands payment for decryption keys
  
  == Modern Threat Landscape
  Emerging attack vectors include custom web applications, supply chain attacks, and sophisticated social engineering campaigns

  == Types of Security Defects
  === Implementation Bugs
  - *Nature*: Localised problems introduced during coding phase
  - *Detection*: Code review and static analysis
  - *Examples*:
    - Using `gets()` instead of `fgets()`
    - SQL injection due to string concatenation
    - Missing input validation
  
  === Design Flaws
  - *Nature*: Architectural and systemic problems
  - *Detection*: Threat modelling and security design review
  - *Examples*:
    - Storing passwords in plaintext without hashing or salting
    - Implementing validation only on the client-side
    - Transmitting credentials over un-encrypted HTTP
  
  === The 50/50 Split
  Security defects are roughly evenly distributed between bugs and flaws, making both code review and design review equally critical

  == Reactive Countermeasures
  === Penetration and Patch Approach
  - *Method*: Address vulnerabilities as they are discovered and exploited
  - *Advantages*: Widely adopted, handles zero-day vulnerabilities
  - *Limitations*:
    - Time lag between discovery and patch release
    - Delay in users installing updates
    - Patches may introduce new vulnerabilities
  
  === Network Security Devices
  - *Purpose*: Block or mitigate attacks at the network level
  - *Examples*:
    - _WAF (Web Application Firewall)_: Filters malicious HTTP traffic
    - _IPS (Intrusion Prevention System)_: Detects and blocks suspicious activity

  == Proactive Countermeasures
  === Secure Development Life Cycle (SDLC)
  - *Principle*: Integrate security considerations at every stage of development
  - *Approach*: Adopt an attacker's mindset during design and implementation
  - *Activities*:
    - Threat modelling during design phase
    - Security-focused code reviews
    - Penetration testing before deployment
    - Security training for development teams
  
  === Balanced Strategy
  While proactive measures significantly reduce vulnerabilities, they cannot anticipate all future attack vectors. A comprehensive security strategy requires both proactive and reactive approaches
]

= Authentication & Authorisation
#container[
  == Authentication Mechanisms
  === Password-Based Authentication
  - *Best Practices*:
    - Use bcrypt, scrypt, or Argon2 for password hashing
    - Implement salting to prevent rainbow table attacks
    - Enforce strong password policies (length, complexity)
    - Enable multi-factor authentication (MFA)
  
  === Token-Based Authentication
  - *JWT (JSON Web Tokens)*: Stateless authentication for distributed systems
  - *OAuth 2.0*: Industry-standard authorisation framework
  - *Session Tokens*: Server-side session management with secure cookies
  
  === Biometric Authentication
  Fingerprint, facial recognition, and iris scanning for high-security applications

  == Authorisation Models
  === Role-Based Access Control (RBAC)
  Users assigned to roles; permissions granted to roles rather than individuals
  
  === Attribute-Based Access Control (ABAC)
  Decisions based on attributes of users, resources, and environmental conditions
  
  === Principle of Least Privilege
  Users should have only the minimum permissions necessary to perform their duties
]

= Network Security
#container[
  == Encryption Protocols
  === Transport Layer Security (TLS)
  - *Purpose*: Secure communication over networks
  - *Use Cases*: HTTPS, email encryption, VPNs
  - *Current Standard*: TLS 1.3 (avoid TLS 1.0 and 1.1)
  
  === IPsec
  Secures IP communications by authenticating and encrypting each packet
  
  === SSH (Secure Shell)
  Provides secure remote access and file transfer capabilities

  == Firewall Types
  === Packet Filtering
  Examines packet headers and filters based on IP addresses, ports, and protocols
  
  === Stateful Inspection
  Tracks connection state and filters based on traffic context
  
  === Application Layer (Proxy)
  Operates at Layer 7, inspecting application-specific protocols (HTTP, FTP, etc.)
  
  === Next-Generation Firewalls (NGFW)
  Combines traditional firewall with IPS, deep packet inspection, and application awareness
]

= Secure Coding Practices
#container[
  == Input Validation
  === Whitelist Approach
  Accept only known-good input patterns (preferred method)
  
  === Sanitisation
  Remove or encode dangerous characters from user input
  
  === Parameterised Queries
  Use prepared statements to prevent SQL injection attacks
  
  === Example Vulnerabilities
  - Cross-Site Scripting (XSS): Unsanitized user input rendered in HTML
  - SQL Injection: Concatenated SQL queries with user input
  - Command Injection: Unvalidated input passed to system commands

  == Output Encoding
  === Context-Aware Encoding
  - *HTML Context*: Encode `<`, `>`, `&`, `"`, `'`
  - *JavaScript Context*: Use JSON serialisation or JavaScript encoding
  - *URL Context*: Apply URL encoding for query parameters
  
  === Content Security Policy (CSP)
  HTTP header that prevents XSS by controlling resource loading sources
]