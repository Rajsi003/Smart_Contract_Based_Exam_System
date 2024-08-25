// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Exam {
    struct Question {
        string questionText;
        string correctAnswer;
    }

    Question[] public questions;
    mapping(address => uint) public scores;
    address public teacher;

    event ScoreSubmitted(address indexed student, uint score);

    constructor() {
        teacher = msg.sender;
    }

    modifier onlyTeacher() {
        require(msg.sender == teacher, "Only the teacher can perform this action.");
        _;
    }

    function addQuestion(string memory questionText, string memory correctAnswer) public onlyTeacher {
        questions.push(Question(questionText, correctAnswer));
    }

    function submitAnswers(string[] memory answers) public {
        require(answers.length == questions.length, "All questions must be answered.");

        uint score = 0;
        for (uint i = 0; i < answers.length; i++) {
            // Normalize both submitted and correct answers
            string memory normalizedAnswer = _normalizeString(answers[i]);
            string memory normalizedCorrectAnswer = _normalizeString(questions[i].correctAnswer);
            
            if (keccak256(abi.encodePacked(normalizedAnswer)) == keccak256(abi.encodePacked(normalizedCorrectAnswer))) {
                score++;
            }
        }

        scores[msg.sender] = score;
        emit ScoreSubmitted(msg.sender, score);
    }

    function getScore() public view returns (uint) {
        return scores[msg.sender];
    }

    function getAllQuestions() public view returns (string[] memory) {
        string[] memory questionTexts = new string[](questions.length);

        for (uint i = 0; i < questions.length; i++) {
            questionTexts[i] = questions[i].questionText;
        }

        return questionTexts;
    }

    // Helper function to normalize a string by converting to lowercase and trimming spaces
    function _normalizeString(string memory str) internal pure returns (string memory) {
        return _toLower(_trim(str));
    }

    // Function to convert a string to lowercase
    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);

        for (uint i = 0; i < bStr.length; i++) {
            // Check if the character is uppercase (A-Z)
            if (bStr[i] >= 0x41 && bStr[i] <= 0x5A) {
                // Convert to lowercase by adding 32 (difference between 'A' and 'a')
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    // Function to trim leading and trailing spaces from a string
    function _trim(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        uint start = 0;
        uint end = bStr.length;

        // Find the first non-space character
        while (start < end && bStr[start] == 0x20) {
            start++;
        }

        // Find the last non-space character
        while (end > start && bStr[end - 1] == 0x20) {
            end--;
        }

        // Create a new bytes array with the trimmed content
        bytes memory trimmed = new bytes(end - start);
        for (uint i = start; i < end; i++) {
            trimmed[i - start] = bStr[i];
        }

        return string(trimmed);
    }
}
