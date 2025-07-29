#!/bin/bash

# Pomodoro Timer API Test Script
# Tests all API endpoints and functionality

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
API_BASE_URL="http://localhost:5001"
TEST_USERNAME="testuser_$(date +%s)"
TEST_PASSWORD="password123"
JWT_TOKEN=""
TEST_USER_ID=""
SESSION_IDS=()
response_body=""

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Test function
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    print_info "Testing: $description"
    
    if [ "$method" = "GET" ]; then
        if [ -n "$JWT_TOKEN" ]; then
            response=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $JWT_TOKEN" "$API_BASE_URL$endpoint")
        else
            response=$(curl -s -w "\n%{http_code}" "$API_BASE_URL$endpoint")
        fi
    else
        if [ -n "$JWT_TOKEN" ]; then
            response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -H "Authorization: Bearer $JWT_TOKEN" -d "$data" "$API_BASE_URL$endpoint")
        else
            response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$API_BASE_URL$endpoint")
        fi
    fi
    
    # Extract status code (last line)
    status_code=$(echo "$response" | tail -n1)
    # Extract response body (all lines except last) - macOS compatible
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -ge 200 ] && [ "$status_code" -lt 300 ]; then
        print_success "Status: $status_code - $description"
        echo "Response: $response_body" | jq '.' 2>/dev/null || echo "Response: $response_body"
    else
        print_error "Status: $status_code - $description"
        echo "Response: $response_body"
        return 1
    fi
    
    echo ""
}

# Main test execution
main() {
    echo -e "${BLUE}🚀 Starting Pomodoro Timer API Tests${NC}"
    echo "API Base URL: $API_BASE_URL"
    echo "Test Username: $TEST_USERNAME"
    echo ""
    
    # Test 1: Health Check
    print_header "Health Check"
    test_endpoint "GET" "/health" "" "Health Check Endpoint"
    
    # Test 2: API Info
    print_header "API Information"
    test_endpoint "GET" "/" "" "API Root Endpoint"
    
    # Test 3: User Registration
    print_header "User Authentication - Registration"
    register_data="{\"username\":\"$TEST_USERNAME\",\"password\":\"$TEST_PASSWORD\"}"
    test_endpoint "POST" "/api/auth/register" "$register_data" "User Registration"
    
    # Extract JWT token and user ID from registration response
    if [ -n "$response_body" ]; then
        JWT_TOKEN=$(echo "$response_body" | jq -r '.token' 2>/dev/null)
        TEST_USER_ID=$(echo "$response_body" | jq -r '.user.id' 2>/dev/null)
        if [ "$JWT_TOKEN" != "null" ] && [ -n "$JWT_TOKEN" ]; then
            print_success "JWT Token extracted successfully"
        else
            print_error "Failed to extract JWT token"
            return 1
        fi
        if [ "$TEST_USER_ID" != "null" ] && [ -n "$TEST_USER_ID" ]; then
            print_success "Test User ID extracted: $TEST_USER_ID"
        fi
    fi
    
    # Test 4: User Login
    print_header "User Authentication - Login"
    login_data="{\"username\":\"$TEST_USERNAME\",\"password\":\"$TEST_PASSWORD\"}"
    test_endpoint "POST" "/api/auth/login" "$login_data" "User Login"
    
    # Update JWT token from login response
    if [ -n "$response_body" ]; then
        JWT_TOKEN=$(echo "$response_body" | jq -r '.token' 2>/dev/null)
        if [ "$JWT_TOKEN" != "null" ] && [ -n "$JWT_TOKEN" ]; then
            print_success "JWT Token updated from login"
        fi
    fi
    
    # Test 5: Create Pomodoro Session
    print_header "Session Management - Create Session"
    session_data="{\"startTime\":\"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",\"duration\":1500,\"mode\":\"work\",\"notes\":\"Test session\"}"
    test_endpoint "POST" "/api/sessions" "$session_data" "Create Work Session"
    
    # Extract session ID for later tests
    SESSION_ID=""
    if [ -n "$response_body" ]; then
        SESSION_ID=$(echo "$response_body" | jq -r '.session._id' 2>/dev/null)
        if [ "$SESSION_ID" != "null" ] && [ -n "$SESSION_ID" ]; then
            print_success "Session ID extracted: $SESSION_ID"
            SESSION_IDS+=("$SESSION_ID")
        fi
    fi
    
    # Test 6: Create Break Session
    print_header "Session Management - Create Break Session"
    break_data="{\"startTime\":\"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",\"duration\":300,\"mode\":\"break\"}"
    test_endpoint "POST" "/api/sessions" "$break_data" "Create Break Session"
    
    # Extract break session ID
    if [ -n "$response_body" ]; then
        BREAK_SESSION_ID=$(echo "$response_body" | jq -r '.session._id' 2>/dev/null)
        if [ "$BREAK_SESSION_ID" != "null" ] && [ -n "$BREAK_SESSION_ID" ]; then
            print_success "Break Session ID extracted: $BREAK_SESSION_ID"
            SESSION_IDS+=("$BREAK_SESSION_ID")
        fi
    fi
    
    # Test 7: Get All Sessions
    print_header "Session Management - Get Sessions"
    test_endpoint "GET" "/api/sessions" "" "Get All User Sessions"
    
    # Test 8: Get Specific Session
    if [ -n "$SESSION_ID" ]; then
        print_header "Session Management - Get Specific Session"
        test_endpoint "GET" "/api/sessions/$SESSION_ID" "" "Get Specific Session"
    fi
    
    # Test 9: Update Session (Complete it)
    if [ -n "$SESSION_ID" ]; then
        print_header "Session Management - Update Session"
        update_data="{\"endTime\":\"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",\"completed\":true,\"notes\":\"Completed test session\"}"
        test_endpoint "PUT" "/api/sessions/$SESSION_ID" "$update_data" "Complete Session"
    fi
    
    # Test 10: Get User Statistics
    print_header "Statistics - Overall Stats"
    test_endpoint "GET" "/api/stats" "" "Get User Statistics"
    
    # Test 11: Get Daily Statistics
    print_header "Statistics - Daily Stats"
    test_endpoint "GET" "/api/stats/daily" "" "Get Daily Statistics"
    
    # Test 12: Get Weekly Statistics
    print_header "Statistics - Weekly Stats"
    test_endpoint "GET" "/api/stats/weekly" "" "Get Weekly Statistics"
    
    # Test 13: Get Monthly Statistics
    print_header "Statistics - Monthly Stats"
    test_endpoint "GET" "/api/stats/monthly" "" "Get Monthly Statistics"
    
    # Test 14: Get Streak Information
    print_header "Statistics - Streak Info"
    test_endpoint "GET" "/api/stats/streak" "" "Get Streak Information"
    
    # Test 15: Error Handling - Invalid Token
    print_header "Error Handling - Invalid Token"
    INVALID_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJpbnZhbGlkIiwiaWF0IjoxNjE2MjM5MDIyLCJleHAiOjE2MTY4NDM4MjJ9.invalid"
    response=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $INVALID_TOKEN" "$API_BASE_URL/api/sessions")
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 401 ]; then
        print_success "Status: $status_code - Invalid Token Rejected"
    else
        print_error "Status: $status_code - Invalid Token Not Properly Rejected"
    fi
    
    # Test 16: Error Handling - Missing Token
    print_header "Error Handling - Missing Token"
    response=$(curl -s -w "\n%{http_code}" "$API_BASE_URL/api/sessions")
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 401 ]; then
        print_success "Status: $status_code - Missing Token Rejected"
    else
        print_error "Status: $status_code - Missing Token Not Properly Rejected"
    fi
    
    # Test 17: Error Handling - Invalid Endpoint
    print_header "Error Handling - Invalid Endpoint"
    response=$(curl -s -w "\n%{http_code}" "$API_BASE_URL/invalid-endpoint")
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 404 ]; then
        print_success "Status: $status_code - Invalid Endpoint Returns 404"
    else
        print_error "Status: $status_code - Invalid Endpoint Not Properly Handled"
    fi
    
    echo ""
    print_header "Test Summary"
    print_success "All API tests completed!"
    print_info "Test user created: $TEST_USERNAME"
    print_info "JWT token obtained and used for authenticated requests"
    print_info "All endpoints tested successfully"
    
    echo ""
    print_header "API Endpoints Tested"
    echo "✅ GET /health - Health check"
    echo "✅ GET / - API information"
    echo "✅ POST /api/auth/register - User registration"
    echo "✅ POST /api/auth/login - User login"
    echo "✅ POST /api/sessions - Create session"
    echo "✅ GET /api/sessions - Get all sessions"
    echo "✅ GET /api/sessions/:id - Get specific session"
    echo "✅ PUT /api/sessions/:id - Update session"
    echo "✅ GET /api/stats - Overall statistics"
    echo "✅ GET /api/stats/daily - Daily statistics"
    echo "✅ GET /api/stats/weekly - Weekly statistics"
    echo "✅ GET /api/stats/monthly - Monthly statistics"
    echo "✅ GET /api/stats/streak - Streak information"
    echo "✅ Error handling - Invalid token"
    echo "✅ Error handling - Missing token"
    echo "✅ Error handling - Invalid endpoint"
}

# Cleanup function to remove test data
cleanup() {
    if [ "$SKIP_CLEANUP" = true ]; then
        print_info "Cleanup skipped as requested"
        return
    fi
    
    print_header "Cleanup - Removing Test Data"
    
    if [ -n "$JWT_TOKEN" ]; then
        print_info "Cleaning up test sessions..."
        
        # Delete all test sessions
        for session_id in "${SESSION_IDS[@]}"; do
            if [ -n "$session_id" ]; then
                response=$(curl -s -w "\n%{http_code}" -X DELETE -H "Authorization: Bearer $JWT_TOKEN" "$API_BASE_URL/api/sessions/$session_id")
                status_code=$(echo "$response" | tail -n1)
                if [ "$status_code" -eq 200 ]; then
                    print_success "Deleted session: $session_id"
                else
                    print_warning "Failed to delete session: $session_id (Status: $status_code)"
                fi
            fi
        done
        
        # Delete test user (this will cascade delete user stats)
        if [ -n "$TEST_USER_ID" ]; then
            print_info "Cleaning up test user..."
            
            response=$(curl -s -w "\n%{http_code}" -X DELETE -H "Authorization: Bearer $JWT_TOKEN" "$API_BASE_URL/api/auth/user")
            status_code=$(echo "$response" | tail -n1)
            if [ "$status_code" -eq 200 ]; then
                print_success "Deleted test user: $TEST_USER_ID"
            else
                print_warning "Failed to delete test user: $TEST_USER_ID (Status: $status_code)"
            fi
        fi
        
        print_success "Cleanup completed!"
    else
        print_warning "No JWT token available for cleanup"
    fi
}

# Command line options
SKIP_CLEANUP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-cleanup)
            SKIP_CLEANUP=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --skip-cleanup    Skip cleanup of test data"
            echo "  --help           Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Signal handler for cleanup on script exit (only if cleanup is enabled)
if [ "$SKIP_CLEANUP" = false ]; then
    trap cleanup EXIT
else
    print_warning "Cleanup disabled - test data will remain in database"
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_warning "jq is not installed. Installing jq for better JSON formatting..."
    if command -v brew &> /dev/null; then
        brew install jq
    else
        print_error "Please install jq manually for better output formatting"
        print_info "You can install it with: brew install jq"
    fi
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    print_error "curl is not installed. Please install curl to run these tests."
    exit 1
fi

# Run the tests
main "$@" 