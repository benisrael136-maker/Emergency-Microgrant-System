# 🆘 Emergency Microgrant System

A comprehensive blockchain-based emergency microgrant distribution system built on the Stacks blockchain, enabling rapid financial assistance to individuals facing urgent situations through a decentralized application, review, and disbursement process.

## 🚀 Features

- **Emergency Grant Applications** 📝: Quick application process for urgent financial assistance
- **Multi-Category Support** 🏷️: Natural disasters, medical emergencies, unemployment, housing, and other crises
- **Priority-Based Processing** ⚡: Critical, high, medium, and low priority classification system
- **Reviewer Network** 👥: Approved reviewer system for application evaluation
- **Emergency Fund Management** 💰: Community-driven emergency funds with contribution tracking
- **Rapid Emergency Response** 🆘: Emergency declaration system for immediate fund disbursement
- **Applicant Profiles** 📈: Track application history and emergency scores
- **Transparent Analytics** 📊: Comprehensive statistics and fund utilization tracking

## 📁 Project Structure

```
Emergency-Microgrant-System/
├── contracts/
│   └── emergency-microgrant-system.clar    # Main smart contract
├── tests/
│   └── emergency-microgrant-system.test.ts # TypeScript tests
├── Clarinet.toml                           # Project configuration
└── README.md                               # This file
```

## 🛠️ Installation & Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Node.js](https://nodejs.org/) (for testing)

### Quick Start
```bash
# Clone the repository
git clone <your-repo-url>
cd Emergency-Microgrant-System

# Check contract syntax
clarinet check

# Run tests
npm install
npm test

# Start local development network
clarinet integrate
```

## 📖 Contract Functions

### Public Functions

#### Fund Management
- `create-emergency-fund` - Create emergency funds with specific categories and initial funding
- `contribute-to-fund` - Contribute STX to existing emergency funds
- `deactivate-fund` - Deactivate emergency funds (fund creator only)

#### Application Process
- `submit-grant-application` - Apply for emergency microgrants with priority classification
- `review-application` - Review and approve/reject applications (reviewers only)
- `disburse-grant` - Distribute approved grants (admin only)

#### Emergency Response
- `declare-emergency` - Declare emergency situations for rapid response (admin only)
- `emergency-disburse` - Bypass review process during emergencies (admin only)

#### Administrative Functions
- `approve-reviewer` - Approve new reviewers (admin only)

### Read-Only Functions
- `get-application` - Retrieve grant application details and status
- `get-emergency-fund` - View emergency fund information and balance
- `get-fund-contribution` - Check contribution records for specific contributors
- `get-applicant-profile` - Access applicant statistics and emergency scores
- `get-reviewer-info` - View reviewer performance and approval rates
- `is-emergency-active` - Check if emergency is currently declared
- `get-application-status` - Get comprehensive application status with timing
- `get-fund-stats` - Analyze fund utilization and availability
- `get-system-stats` - Platform-wide statistics and metrics

## 🎯 Usage Examples

### Creating an Emergency Fund
```clarity
(contract-call? .emergency-microgrant-system create-emergency-fund
  "Hurricane Relief Fund"  ;; Fund name
  u0                       ;; Natural disaster category
  u10000000               ;; Initial funding: 10 STX
)
```

### Contributing to a Fund
```clarity
(contract-call? .emergency-microgrant-system contribute-to-fund
  u1        ;; Fund ID
  u2000000  ;; Contribute 2 STX
)
```

### Submitting a Grant Application
```clarity
(contract-call? .emergency-microgrant-system submit-grant-application
  u1                                          ;; Medical emergency
  u1500000                                    ;; Request 1.5 STX
  u0                                          ;; Critical priority
  "Urgent medical treatment needed for heart condition requiring immediate surgery"  ;; Description
  "Miami, Florida"                           ;; Location
)
```

### Reviewing an Application (Reviewer)
```clarity
(contract-call? .emergency-microgrant-system review-application
  u1        ;; Application ID
  true      ;; Approve
  u1200000  ;; Approve 1.2 STX (partial amount)
)
```

### Disbursing a Grant (Admin)
```clarity
(contract-call? .emergency-microgrant-system disburse-grant
  u1  ;; Application ID
)
```

### Declaring Emergency (Admin)
```clarity
(contract-call? .emergency-microgrant-system declare-emergency
  u0                                          ;; Natural disaster type
  "Category 5 hurricane approaching coast"   ;; Description
  u1440                                       ;; Duration: 10 days
)
```

### Emergency Disbursement (Admin)
```clarity
(contract-call? .emergency-microgrant-system emergency-disburse
  u1  ;; Application ID (bypasses review process)
)
```

### Approving a Reviewer (Admin)
```clarity
(contract-call? .emergency-microgrant-system approve-reviewer
  'SP-REVIEWER-PRINCIPAL-ADDRESS  ;; New reviewer address
)
```

## 📊 Application Status Flow

```
PENDING (0) → Review Process → APPROVED (1) → DISBURSED (3)
     ↓                              ↓
EXPIRED (4)                    REJECTED (2)
```

## 🏷️ Emergency Categories

```
NATURAL_DISASTER (0) - Hurricanes, earthquakes, floods, fires
MEDICAL (1)          - Medical emergencies and healthcare needs
UNEMPLOYMENT (2)     - Job loss and income emergencies
HOUSING (3)          - Housing crises and eviction prevention
OTHER (4)            - Other urgent situations
```

## ⚡ Priority Levels

```
CRITICAL (0) - Life-threatening emergencies requiring immediate response
HIGH (1)     - Urgent situations requiring rapid response
MEDIUM (2)   - Important needs requiring timely response
LOW (3)      - Standard processing for non-urgent situations
```

## 💼 Business Model

### Grant Limits
- **Minimum Grant**: 0.1 STX to prevent spam applications
- **Maximum Grant**: 5 STX to ensure fair distribution
- **Application Validity**: 4,320 blocks (~30 days) before expiration
- **Emergency Response**: 144 blocks (~1 day) for emergency processing

### Fund Structure
- **Community Funding**: Anyone can create and contribute to emergency funds
- **Category-Specific**: Funds designated for specific emergency types
- **Transparent Usage**: All fund utilization publicly tracked
- **Creator Control**: Fund creators can deactivate their funds

## 🔒 Security Features

- **Reviewer Authorization**: Only approved reviewers can evaluate applications
- **Admin Controls**: Contract admin manages reviewers and emergency declarations
- **Fund Creator Rights**: Fund creators control their fund activation status
- **Application Limits**: Grant amount limits prevent fund depletion abuse
- **Emergency Protocols**: Emergency declarations enable rapid response
- **Transparent Tracking**: All transactions publicly verifiable
- **Automatic Expiry**: Applications expire after validity period

## 💡 Use Cases

### Natural Disaster Response
- **Hurricane Relief**: Immediate assistance for storm victims
- **Earthquake Recovery**: Emergency funds for seismic disaster victims
- **Flood Assistance**: Rapid aid for flood-affected communities
- **Wildfire Support**: Emergency relief for fire evacuation and recovery

### Medical Emergencies
- **Emergency Surgery**: Urgent medical procedure funding
- **Prescription Assistance**: Critical medication access
- **Emergency Transport**: Medical transportation costs
- **Hospital Bills**: Emergency medical expense assistance

### Economic Hardship
- **Unemployment Relief**: Temporary assistance during job loss
- **Utility Payments**: Emergency utility bill assistance
- **Food Security**: Emergency food and nutrition assistance
- **Transportation**: Emergency transportation for job interviews or work

### Housing Crises
- **Eviction Prevention**: Emergency rent assistance
- **Temporary Shelter**: Emergency housing costs
- **Utility Deposits**: Security deposits for new housing
- **Moving Expenses**: Emergency relocation assistance

## 🎨 Stakeholder Benefits

### For Applicants
- **Rapid Access** ⚡: Quick application process for urgent needs
- **Fair Review** ⚖️: Independent reviewer network ensures fairness
- **Multiple Categories** 🏷️: Support for various emergency types
- **Priority System** 🔄: Critical situations receive priority processing
- **Transparent Process** 🔍: Clear application status and tracking

### For Contributors
- **Targeted Giving** 🎯: Contribute to specific emergency categories
- **Impact Tracking** 📈: Monitor fund utilization and impact
- **Community Building** 🤝: Build emergency response communities
- **Transparent Usage** 🔍: See exactly how contributions are used
- **Global Reach** 🌍: Support emergencies worldwide

### For Reviewers
- **Community Service** 🎆: Serve community through application review
- **Performance Tracking** 📈: Track review statistics and approval rates
- **Fair Compensation** 💰: Potential future reviewer incentives
- **Impact Measurement** 🎯: See direct impact of review decisions
- **Reputation Building** ⭐: Build reputation through quality reviews

## 📈 Platform Analytics

The contract provides comprehensive analytics:
- **Application Metrics**: Track application volume and approval rates
- **Fund Performance**: Monitor fund utilization and contribution patterns
- **Emergency Response**: Analyze emergency declaration and response times
- **Category Analysis**: Understand distribution across emergency types
- **Geographic Trends**: Track emergency patterns by location
- **Reviewer Performance**: Monitor reviewer efficiency and accuracy

## 🧪 Testing

Run the comprehensive test suite:

```bash
npm install
npm test
```

Tests cover:
- Emergency fund creation and management
- Grant application submission and processing
- Review workflow and approval processes
- Emergency declaration and rapid response
- Fund contribution and tracking systems
- Reviewer management and statistics
- Administrative controls and security
- Error handling and edge cases

## 🚦 Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 401 | ERR_UNAUTHORIZED | Access denied for operation |
| 402 | ERR_APPLICATION_NOT_FOUND | Application ID doesn't exist |
| 403 | ERR_INSUFFICIENT_FUNDS | Insufficient funds for operation |
| 404 | ERR_INVALID_AMOUNT | Invalid amount specified |
| 405 | ERR_ALREADY_APPLIED | Duplicate application detected |
| 406 | ERR_APPLICATION_CLOSED | Application period has ended |
| 407 | ERR_INVALID_STATUS | Invalid status for operation |
| 408 | ERR_EMERGENCY_DECLARED | Emergency already declared |
| 409 | ERR_NO_EMERGENCY | No emergency currently declared |
| 410 | ERR_FUND_NOT_FOUND | Emergency fund doesn't exist |

## 🌟 Platform Benefits

- **Rapid Response** ⚡: Emergency declarations enable immediate assistance
- **Decentralized Fairness** ⚖️: Community reviewers ensure fair evaluation
- **Global Accessibility** 🌐: Anyone worldwide can apply for or contribute assistance
- **Transparent Operations** 📊: All transactions publicly verifiable
- **Community-Driven** 🤝: Community creates and funds emergency assistance
- **Automated Processing** 🤖: Smart contracts handle fund management
- **Permanent Records** 📜: Immutable record of all emergency assistance

## 🎯 Target Users

- **Individuals in Crisis**: People facing urgent financial emergencies
- **Disaster Response Organizations**: NGOs and emergency response groups
- **Community Organizations**: Local groups providing emergency assistance
- **Philanthropists**: Individual donors supporting emergency relief
- **Government Agencies**: Public sector emergency response units
- **Healthcare Providers**: Medical organizations assisting with emergencies
- **Social Workers**: Professionals identifying emergency assistance needs

## 🌟 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add comprehensive tests
5. Run `clarinet check` to validate
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🤝 Support

For questions or support:
- Create an issue on GitHub
- Check the [Stacks documentation](https://docs.stacks.co/)
- Visit the [Clarinet documentation](https://docs.hiro.so/stacks/clarinet-js-sdk)

## 🚀 Deployment

Ready for deployment on:
- **Stacks Testnet**: For testing and development
- **Stacks Mainnet**: For production emergency assistance

---

Built with ❤️ for emergency response and community support using Stacks blockchain technology.
