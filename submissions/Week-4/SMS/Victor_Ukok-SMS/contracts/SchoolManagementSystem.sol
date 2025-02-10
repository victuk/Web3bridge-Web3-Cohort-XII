// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract SchoolManagementSystem {
    uint public unlockTime;
    address payable public owner;
    uint256 id;

    event PaymentReceived(
        address indexed from,
        StudentClass studentClass,
        uint amount
    );
    event UserAdded(
        address indexed ownerAddress,
        address userAddress,
        string name,
        uint age
    );

    event StudentRecordAdded(
        address indexed teacherAddress,
        address studentAddress,
        string subject,
        uint8 test1,
        uint8 test2,
        uint8 test3,
        uint8 exam
    );

    event OwnershipTransfer(address formerPrincipal, address currentPrincipal);

    constructor() {
        owner = payable(msg.sender);
    }

    enum UserTypes {
        Student,
        Teacher
    }

    enum Gender {
        Male,
        Female
    }

    struct UserStruct {
        string fullName;
        uint16 age;
        Gender gender;
        string[] subjects;
        UserTypes userType;
        bool suspended;
    }

    enum StudentClass {
        JS1,
        JS2,
        JS3,
        SS1,
        SS2,
        SS3
    }

    struct StudentRecord {
        string subject;
        uint8 test1;
        uint8 test2;
        uint8 test3;
        uint8 exam;
    }

    mapping(address => mapping(StudentClass => uint)) public studentFeePaid;

    mapping(address => mapping(StudentClass => StudentRecord[]))
        public studentRecord;

    mapping(address => UserStruct) public users;

    modifier onlyOwner() {
        require(owner == msg.sender, "Only the principal can take this action");
        _;
    }

    modifier onlyTeacher() {
        require(
            users[msg.sender].userType == UserTypes.Teacher,
            "Only teachers can take this action"
        );
        _;
    }

    function addUser(
        string memory _fullName,
        uint16 _age,
        Gender _gender,
        string[] memory _subjects,
        UserTypes _userType,
        address _userAddress
    ) external {
        require(bytes(_fullName).length > 0, "Full name should not be empty");
        require(_age > 0, "Age must be greater than 0");
        require(
            _subjects.length <= 5 && _subjects.length > 0,
            "Subjects must be between 1 and 5"
        );
        users[_userAddress] = UserStruct({
            fullName: _fullName,
            age: _age,
            gender: _gender,
            subjects: _subjects,
            userType: _userType,
            suspended: false
        });
    }

    function getStudent(
        address _studentAddress
    ) public view returns (UserStruct memory) {
        return users[_studentAddress];
    }

    function getStudentPayment(
        address _studentAddress,
        StudentClass _studentClass
    ) public view returns (uint256) {
        return studentFeePaid[_studentAddress][_studentClass];
    }

    function addStudent(
        string memory _fullName,
        uint16 _age,
        Gender _gender,
        string[] memory _subjects,
        UserTypes _userType,
        address _userAddress
    ) external onlyOwner {
        users[_userAddress] = UserStruct({
            fullName: _fullName,
            age: _age,
            gender: _gender,
            subjects: _subjects,
            userType: _userType,
            suspended: false
        });

        emit UserAdded(msg.sender, _userAddress, _fullName, _age);
    }

    function payFee(StudentClass _studentClass) external payable {
        require(msg.value == 10, "You are to send 10 Wei");
        studentFeePaid[msg.sender][_studentClass] =
            studentFeePaid[msg.sender][_studentClass] +
            msg.value;
        emit PaymentReceived(msg.sender, _studentClass, msg.value);
    }

    function addRecord(
        address _studentAddress,
        StudentClass _studentClass,
        string memory _subject,
        uint8 _test1,
        uint8 _test2,
        uint8 _test3,
        uint8 _exam
    ) external onlyTeacher {
        StudentRecord[] storage studentRecordArray = studentRecord[
            _studentAddress
        ][_studentClass];

        for (uint i = 0; i < studentRecordArray.length; i++) {
            if (
                keccak256(abi.encodePacked(studentRecordArray[i].subject)) ==
                keccak256(abi.encodePacked(_subject))
            ) {
                studentRecordArray[i].test1 = _test1;
                studentRecordArray[i].test2 = _test2;
                studentRecordArray[i].test3 = _test3;
                studentRecordArray[i].exam = _exam;
                return;
            }
        }

        studentRecordArray.push(
            StudentRecord({
                subject: _subject,
                test1: _test1,
                test2: _test2,
                test3: _test3,
                exam: _exam
            })
        );

        emit StudentRecordAdded(
            msg.sender,
            _studentAddress,
            _subject,
            _test1,
            _test2,
            _test3,
            _exam
        );
    }

    function getStudentRecord(
        address _studentAddress,
        StudentClass _studentClass
    ) external view returns (StudentRecord[] memory) {
        return studentRecord[_studentAddress][_studentClass];
    }

    function handOverOwnership(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
        emit OwnershipTransfer(msg.sender, _newOwner);
    }

    function getSchoolBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}
