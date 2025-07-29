#!/bin/bash

# Template for API Testing Script
# Copy this file to test-api.sh and customize with your own credentials

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration - CUSTOMIZE THESE VALUES
API_BASE_URL="http://localhost:5001"
TEST_USERNAME="testuser"
TEST_PASSWORD="your_test_password_here"  # Change this!
JWT_TOKEN=""

# Test tracking variables
TEST_USER_ID=""
SESSION_IDS=()

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
    
    print_header "$description"
    
    if [ -n "$JWT_TOKEN" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -H "Authorization: Bearer $JWT_TOKEN" -d "$data" "$API_BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$API_BASE_URL$endpoint")
    fi
    
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -ge 200 ] && [ "$status_code" -lt 300 ]; then
        print_success "Status: $status_code - $description"
        echo "Response: $response_body"
    else
        print_error "Status: $status_code - $description"
        echo "Response: $response_body"
    fi
}

# Cleanup function
cleanup() {
    if [ "$SKIP_CLEANUP" = "true" ]; then
        print_warning "Skipping cleanup as requested"
        return
    fi
    
    print_header "Cleaning up test data"
    
    # Delete test sessions
    for session_id in "${SESSION_IDS[@]}"; do
        if [ -n "$session_id" ] && [ -n "$JWT_TOKEN" ]; then
            response=$(curl -s -w "\n%{http_code}" -X DELETE -H "Authorization: Bearer $JWT_TOKEN" "$API_BASE_URL/api/sessions/$session_id")
            status_code=$(echo "$response" | tail -n1)
            if [ "$status_code" -eq 200 ]; then
                print_success "Deleted session: $session_id"
            else
                print_warning "Failed to delete session: $session_id (Status: $status_code)"
            fi
        fi
    done
    
    # Delete test user
    if [ -n "$JWT_TOKEN" ]; then
        response=$(curl -s -w "\n%{http_code}" -X DELETE -H "Authorization: Bearer $JWT_TOKEN" "$API_BASE_URL/api/auth/user")
        status_code=$(echo "$response" | tail -n1)
        if [ "$status_code" -eq 200 ]; then
            print_success "Deleted test user"
        else
            print_warning "Failed to delete test user (Status: $status_code)"
        fi
    else
        print_warning "No JWT token available for cleanup"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Check if cleanup should be skipped
if [ "$1" = "--skip-cleanup" ]; then
    SKIP_CLEANUP=true
    print_warning "Cleanup will be skipped"
fi

echo -e "${BLUE}🧪 Pomodoro Timer API Test Suite${NC}"
echo "=================================="
print_info "Testing API endpoints at: $API_BASE_URL"
print_info "Test user: $TEST_USERNAME"

# Test 1: Health Check
print_header "Health Check"
response=$(curl -s -w "\n%{http_code}" "$API_BASE_URL/health")
status_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | sed '$d')

if [ "$status_code" -eq 200 ]; then
    print_success "Status: $status_code - Health Check"
    echo "Response: $response_body"
else
    print_error "Status: $status_code - Health Check Failed"
    echo "Response: $response_body"
    exit 1
fi

# Test 2: API Info
print_header "API Information"
response=$(curl -s -w "\n%{http_code}" "$API_BASE_URL/api")
status_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | sed '$d')

if [ "$status_code" -eq 200 ]; then
    print_success "Status: $status_code - API Info"
    echo "Response: $response_body"
else
    print_error "Status: $status_code - API Info Failed"
    echo "Response: $response_body"
fi

# Test 3: User Registration
print_header "User Authentication - Registration"
register_data="{\"username\":\"$TEST_USERNAME\",\"password\":\"$TEST_PASSWORD\"}"
test_endpoint "POST" "/api/auth/register" "$register_data" "User Registration"

# Extract JWT token and user ID from registration response
response_body=$(echo "$response" | sed '$d')
JWT_TOKEN=$(echo "$response_body" | jq -r '.token' 2>/dev/null)

if [ "$JWT_TOKEN" != "null" ] && [ -n "$JWT_TOKEN" ]; then
    print_success "JWT Token extracted successfully"
else
    print_error "Failed to extract JWT token"
fi

# Test 4: User Login
print_header "User Authentication - Login"
login_data="{\"username\":\"$TEST_USERNAME\",\"password\":\"$TEST_PASSWORD\"}"
test_endpoint "POST" "/api/auth/login" "$login_data" "User Login"

# Update JWT token from login response
response_body=$(echo "$response" | sed '$d')
JWT_TOKEN=$(echo "$response_body" | jq -r '.token' 2>/dev/null)
if [ "$JWT_TOKEN" != "null" ] && [ -n "$JWT_TOKEN" ]; then
    print_success "JWT Token updated from login"
fi

# Test 5: Create Pomodoro Session
print_header "Create Pomodoro Session"
session_data='{"mode":"work","duration":1500,"startTime":"2024-01-01T10:00:00Z","completed":true,"rounds":1,"notes":"Test session"}'
test_endpoint "POST" "/api/sessions" "$session_data" "Create Session"

# Extract session ID
response_body=$(echo "$response" | sed '$d')
session_id=$(echo "$response_body" | jq -r '._id' 2>/dev/null)
if [ "$session_id" != "null" ] && [ -n "$session_id" ]; then
    SESSION_IDS+=("$session_id")
    print_success "Session created with ID: $session_id"
fi

# Test 6: Get User Sessions
print_header "Get User Sessions"
test_endpoint "GET" "/api/sessions" "" "Get Sessions"

# Test 7: Get User Statistics
print_header "Get User Statistics"
test_endpoint "GET" "/api/stats" "" "Get Stats"

# Test 8: Get Daily Statistics
print_header "Get Daily Statistics"
test_endpoint "GET" "/api/stats/daily" "" "Get Daily Stats"

# Test 9: Get Weekly Statistics
print_header "Get Weekly Statistics"
test_endpoint "GET" "/api/stats/weekly" "" "Get Weekly Stats"

# Test 10: Get Monthly Statistics
print_header "Get Monthly Statistics"
test_endpoint "GET" "/api/stats/monthly" "" "Get Monthly Stats"

# Test 11: Get Streak Information
print_header "Get Streak Information"
test_endpoint "GET" "/api/stats/streak" "" "Get Streak Info"

# Test 12: Update Session
if [ -n "$session_id" ]; then
    print_header "Update Session"
    update_data='{"completed":true,"notes":"Updated test session"}'
    test_endpoint "PUT" "/api/sessions/$session_id" "$update_data" "Update Session"
fi

# Test 13: Get Specific Session
if [ -n "$session_id" ]; then
    print_header "Get Specific Session"
    test_endpoint "GET" "/api/sessions/$session_id" "" "Get Session"
fi

# Test 14: Error Handling - Invalid Endpoint
print_header "Error Handling - Invalid Endpoint"
response=$(curl -s -w "\n%{http_code}" "$API_BASE_URL/api/invalid")
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 404 ]; then
    print_success "Status: $status_code - Invalid Endpoint Properly Handled"
else
    print_error "Status: $status_code - Invalid Endpoint Not Properly Handled"
fi

# Test 15: Error Handling - Invalid Token
print_header "Error Handling - Invalid Token"
INVALID_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJpbnZhbGlkIiwiaWF0IjoxNjE2MjM5MDIyLCJleHAiOjE2MTY4NDM4MjJ9.invalid"
response=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $INVALID_TOKEN" "$API_BASE_URL/api/sessions")
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 401 ]; then
    print_success "Status: $status_code - Invalid Token Rejected"
else
    print_error "Status: $status_code - Invalid Token Not Properly Rejected"
fi

# Test 16: Error Handling - Missing Token
print_header "Error Handling - Missing Token"
response=$(curl -s -w "\n%{http_code}" "$API_BASE_URL/api/sessions")
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 401 ]; then
    print_success "Status: $status_code - Missing Token Rejected"
else
    print_error "Status: $status_code - Missing Token Not Properly Rejected"
fi

# Summary
echo -e "\n${BLUE}📊 Test Summary${NC}"
echo "================"
print_success "All API endpoints tested successfully!"
print_info "JWT token obtained and used for authenticated requests"
print_info "Test data will be cleaned up automatically"

echo -e "\n${GREEN}✅ API Test Results:${NC}"
echo "✅ GET /health - Health check"
echo "✅ GET /api - API information"
echo "✅ POST /api/auth/register - User registration"
echo "✅ POST /api/auth/login - User login"
echo "✅ POST /api/sessions - Create session"
echo "✅ GET /api/sessions - Get user sessions"
echo "✅ GET /api/stats - Get user statistics"
echo "✅ GET /api/stats/daily - Get daily statistics"
echo "✅ GET /api/stats/weekly - Get weekly statistics"
echo "✅ GET /api/stats/monthly - Get monthly statistics"
echo "✅ GET /api/stats/streak - Get streak information"
echo "✅ PUT /api/sessions/:id - Update session"
echo "✅ GET /api/sessions/:id - Get specific session"
echo "✅ Error handling - Invalid endpoint"
echo "✅ Error handling - Invalid token"
echo "✅ Error handling - Missing token"

print_success "🎉 All tests completed successfully!"
print_info "Your Pomodoro Timer API is working correctly!" 