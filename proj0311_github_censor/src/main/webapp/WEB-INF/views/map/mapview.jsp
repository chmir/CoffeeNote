<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="_csrf" content="${_csrf.token}" />
<meta name="_csrf_header" content="${_csrf.headerName}" />
<title>지도 검색 - 카페</title>

<!-- 지도 스타일 링크 -->
<link rel="stylesheet" type="text/css" href="/css/mapviewStyle/mapview.css"/>

<!-- 카카오 맵 호출 API -->
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=*검열*&libraries=services"></script>

<!-- jQuery 호출 -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- 검색창 돋보기 아이콘 -->
<script src="https://kit.fontawesome.com/427caf46c6.js" crossorigin="anonymous"></script> 
</head>


<body>
<!-- 로딩 이미지 -->
<img id="loadingSpinner" src="/images/buffering.gif" alt="Loading...">

<!-- 카카오 맵 로드 -->
<div id="map"></div>


<!-- 제어 버튼 영역 -->

<div id="controlButtons">
	<!-- Buttons -->
	
	<!-- 현재 위치 이동 버튼 -->
	<div id="currentLocationButton" onclick="moveToCurrentLocation()">
	    <span class="tooltip" title="현재 위치로 이동">
	        <img alt="현재 위치" src="/images/mapview/location/currentLocation.png" width="35px" height="35px">
	    </span>
	</div>
	
	<!-- 북마크 열기 버튼 -->
	<div id="bookmarkListButton" onclick="showBookmarkListModal()">
		<span id="bookmarkTooltip" class="tooltip" title="북마크 리스트 열기">
			<img id="bookmarkButtonImage" src="/images/mapview/bookmark/bookmark.png" width=35px; height=35px;>
		</span>
	</div>
	
	<!-- 북마크 생성 버튼 -->
	<div id="createBookmarkButton" onclick="showBookmarkCreateModal()">
		<span id="createBookmarkButtonTooltip" class="tooltip" title="북마크 생성하기">
			<img id="createBookmarkButtonImage" src="/images/mapview/bookmark/createbookmark.png" width=35px; height=35px;>
		</span>
	</div>
	
	
	<!-- 홈 버튼 -->
	<div id="homeButton" onclick="movetoIndex()">
		<span class="tooltip" title="홈으로 이동">
			<img alt="" src="/images/mapview/home/home.png" width=40px; height=40px;>
		</span>
	</div>
	
	
	
	
</div>


<!-- 0910 추가 - Bookmark Details Modal -->
<!-- 북마크 상세정보 모달 -->
<div id="bookmarkDetailsModal" style="display: none;">
    <div id="closeBookmarkDetailsButton" onclick="hideBookmarkDetailsModal()">X</div>
    <h3>북마크 상세 정보</h3>
    <div>
        <strong>제목:</strong> <span id="bookmarkTitle"></span><br>
        <strong>설명:</strong> <span id="bookmarkContent"></span><br>
        <strong>작성자:</strong> <span id="bookmarkUserName"></span><br>
        <c:choose>
            <c:when test="${not empty loggedInUserId}">
                <!-- 좋아요 버튼에 ID 추가 -->
                <img id="bookmarkLikeButton"
                     class="like-icon" 
                     data-bookmark-id="" 
                     data-liked="" 
                     src="/images/unlike.png" 
                     onclick="toggleBookmarkLike(event, this)" />
            </c:when>
            <c:otherwise>
                <!-- 로그인하지 않은 사용자일 경우 좋아요 버튼 비활성화 -->
                <img src="/images/unlike.png" class="like-icon" />
            </c:otherwise>
        </c:choose>
        <strong>좋아요:</strong> <span id="bookmarkLikes"></span><br>
    </div>
</div>


<!-- Bookmark Create Modal -->
<div id="bookmarkCreateModal">
    <!-- <div id="closeModalButton" onclick="hideBookmarkCreateModal()">X</div>  -->
    <h2>북마크 생성을 시작합니다.</h2>
    <form id="bookmarkForm" action="<c:url value='/map/bookmarkcreate'/>" method="post">
    
    	<!-- Step 1: 안내 문구 -->
        <div id="createBookmarkStep1" class="step active">
            <p>북마크를 생성하기 전 <br> 추가할 카페 또는 장소를 검색 후 진행해 주세요.</p>
        </div>
        
        <!-- Step 2: 북마크 제목 입력 -->
        <div id="createBookmarkStep2" class="step">
	        <p>먼저 북마크 제목을 입력해주세요.</p>
	        <input type="text" id="bookmarkTitle" name="title" placeholder="여기에 북마크 제목을 입력합니다..."><br>
        </div>
        
        <!-- Step 3: 북마크 설명 입력 -->
        <div id="createBookmarkStep3" class="step">
        	<p>해당 북마크에 대한 설명을 입력해주세요.</p>
	        <textarea id="bookmarkExplain" name="content" placeholder="여기에 북마크에 대한 설명을 입력합니다..."></textarea><br>
        </div>
        
        <!-- Step 4: 카페 선택 -->
        <div id="createBookmarkStep4" class="step">
        	<p>이제 북마크에 저장할 카페를 <br> 왼쪽에 검색된 리스트에서 선택해주세요.</p>
        </div>
        
        <!-- Step 5: 전체 공개 여부 -->
        <div id="createBookmarkStep5" class="step">
        	<p>전체 공개 여부를 선택해주세요.</p>
        	<label><input type="checkbox" id="isPublicCheckbox" name="isPublic"> 전체 공개</label><br>
        </div>
              
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
        <input type="hidden" id="selectedCafesInput" name="selectedCafes">
        
		<!-- 동작 버튼 -->
		<div id="actionButton">
	        <button type="button" id="prevButton" style="display: none;">이전</button>
			<button type="button" id="nextButton">다음</button>
	        <button type="submit" id="submitButton">북마크 생성하기</button>
        </div>
    </form>
</div>


<!-- Bookmark List Modal -->
<div id="bookmarkListModal">
    <!-- <div id="closeBookmarkListButton" onclick="hideBookmarkListModal()">X</div> -->
    <h3>북마크 리스트</h3>
    <!-- 0910 - 북마크 검색창 추가 -->
    <div id="searchBookmark">
        <input type="text" id="bookmarkSearchInput" placeholder="북마크 제목을 검색하세요.">
        <button onclick="searchBookmarks()">
        	<i class="fa-solid fa-magnifying-glass"></i>
        </button>
    </div>
    <ul id="bookmarkList" style="list-style: none; padding: 0;">
        <c:forEach var="bookmark" items="${bookmarkList}">
            <li class="bookmark-item" onclick="showCafesByBookmark(${bookmark.bookmarkId})">
                <strong>북마크 제작자: ${bookmark.userName} (${bookmark.userId})</strong><br>
                제목: ${bookmark.title}<br>
                설명: ${bookmark.content}<br>
                <br>
                <c:choose>
                    <c:when test="${not empty loggedInUserId}">
                        <!-- 북마크 상세정보 창에서 좋아요 버튼 -->
						<img class="like-icon" 
						     data-bookmark-id="${bookmark.bookmarkId}" 
						     data-liked="${bookmark.liked}" 
						     src="<c:out value='${bookmark.liked ? "/images/like.png" : "/images/unlike.png"}'/>" 
						     onclick="toggleBookmarkLike(event, this)" />
                    </c:when>
                    <c:otherwise>
                        <!-- 로그인하지 않은 사용자일 경우 좋아요 버튼 비활성화 -->
                        <img src="/images/unlike.png" class="like-icon" />
                    </c:otherwise>
                </c:choose>
                <span class="like-count">${bookmark.likes}</span>
            </li>
        </c:forEach>
    </ul>
</div>



<!-- Cafe Info Modal (moved below Bookmark List Modal) -->
<div id="cafeInfoModal">
    <div id="closeCafeInfoButton" onclick="hideCafeInfoModal()">&#x2716;</div>
    <h1 id="cafeInfoTitle" style="color: #00897B; text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);"></h1>

    <p id="cafeInfoContent" style="font-size: 20px; color: #2C3E50;"></p>
    
	<!-- 이미지 갤러리 추가 -->
    <div id="imageGallery">
    	<!-- <img src="https://img.freepik.com/premium-vector/add-post-icon-line-icon_707519-2569.jpg?w=1380" width="80px" height="auto" onclick="showReviewModal()"> -->
        <!-- 여기에 이미지가 동적으로 추가됩니다 -->
    </div>

    <div style="display: flex; justify-content: space-between;">
        <!-- 광고(홍보) 목록 영역 -->
        <div id="advertisingList" style="width: 48%;">
            <h4>홍보 목록</h4>
            <!-- JavaScript로 동적으로 홍보 목록이 추가될 것입니다 -->
        </div>

        <!-- 리뷰 목록 영역 -->
        <div id="reviewList" style="width: 48%;">
            <h4>리뷰 목록</h4>
            <!-- JavaScript로 동적으로 리뷰 목록이 추가될 것입니다 -->
        </div>
    </div>
    
    
    <!-- 0923 추가 비로그인 상태면 해당 버튼들이 보이지 않음 -->
    <sec:authorize access="isAuthenticated()">
		<div id="cafeInfoButton">
		    <!-- 홍보 추가 버튼 -->
		    <button id="promotionButton" onclick="redirectToAdvertisingPage()">내 카페 홍보하러 가기</button>
		    
		    <!-- 리뷰 추가 버튼 -->
		    <button id="reviewButton" onclick="showReviewModal()">리뷰 작성하기</button>
		</div>
    </sec:authorize>
</div>



<!-- Review Modal -->
<div id="reviewModal">
    <div id="closeReviewButton" onclick="hideReviewModal()">&#x2716;</div>
    <h3>리뷰 작성</h3>
    <form id="reviewForm" action="<c:url value='/map/addreview?${_csrf.parameterName}=${_csrf.token}'/>" method="post" enctype="multipart/form-data">

        <!-- 리뷰 제목 입력란 -->
        <input type="text" name="title" placeholder="리뷰 제목" required>

        <!-- 리뷰 내용 입력란 -->
        <textarea name="content" placeholder="리뷰 내용" required></textarea>

        <!-- 별점 선택 -->
        <label id="ratingLabel">
            <select name="rating" id="ratingSelect" required>
            	<option value="" disabled selected>별점 선택</option> <!-- 기본 옵션 설정 -->
                <option value="1">1점&nbsp;⭐</option>
				<option value="2">2점&nbsp;⭐⭐</option>
				<option value="3">3점&nbsp;⭐⭐⭐</option>
				<option value="4">4점&nbsp;⭐⭐⭐⭐</option>
				<option value="5">5점&nbsp;⭐⭐⭐⭐⭐</option>
            </select>
        </label>

        <!-- 파일 첨부 -->
        <label for="file-upload" id="customButton">
            이미지 첨부
        </label>

        <!-- 파일 업로드 숨기기 -->
        <input id="file-upload" type="file" name="images" multiple>
        
        <!-- 리뷰작성 시 전송될 CN_Cafe에 필요한 정보와 사진들... -->
        <input type="hidden" name="cafeId" id="reviewCafeId">
        <input type="hidden" name="cafeX" id="reviewCafeX">
        <input type="hidden" name="cafeY" id="reviewCafeY">
        <input type="hidden" name="cafeName" id="reviewCafeName">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <button type="submit">리뷰 등록</button>

    </form>
</div>





<div id="searchListForm">

	<!-- 사이드바 검색 영역 숨기기 버튼 -->
	<button id="hideFormbutton">
		<img src="/images/mapview/form/hideForm.png" width=40px; height=40px;>
	</button>

	<div id="searchListTitle">
		<a href="/">커 피 노 트</a>
	</div>
	
	<!-- 검색창 영역 -->
	<div id="searchForm">
	    <form action="/map/searchmap" method="post" accept-charset="UTF-8" onsubmit="showLoadingSpinner()">
	        <input type="text" name="keyword" id="keywordInput" placeholder="카페 또는 장소를 검색하세요." style="padding: 5px;" required>
	        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
	        
	        
            <!-- 검색창 Clear 버튼 -->
	        <button id="clear-button" type="button" onclick="clearSearch()">
            	&#x2716;
        	</button>
        	
	        <!-- 검색 버튼 -->
	        <button id="search-button" type="submit">
	            <i class="fa-solid fa-magnifying-glass"></i>
	        </button>
	    </form>
	</div>
	

	<!-- 검색 결과 로드 영역 -->
	<div id="listForm">
	    <c:choose>
	        <c:when test="${not empty cafeDetailsList}">
	            <ul style="list-style: none; padding: 0;">
	                <c:forEach var="cafe" items="${cafeDetailsList}" varStatus="status">
	                    <li class="cafe-item" onclick="moveToMarker(${status.index}); toggleCafeSelection(${status.index});">
	                        <strong id="placeName">${cafe.placeName}</strong><br>
	                        지번주소: ${cafe.addressName}<br>
	                        도로명주소: ${cafe.roadAddressName}<br>
	                        전화번호: ${cafe.phone}<br>
	                        <a href="${cafe.placeUrl}" target="_blank">자세히 보기</a>
	                    </li>
	                </c:forEach>
	            </ul>
	        </c:when>
	        <c:otherwise>
	            <p id="listText">검색 시 이곳에 정보가 표시됩니다.</p>
	        </c:otherwise>
	    </c:choose>
	</div>
	
</div>
<!-- 이게 옛날 북마크 검색 방식인데 나중에 /mapview/{bookmarkId} 이거로 통합 -->
<!-- 
<form id="filterForm" action="/map/filterByBookmark" method="post" style="display:none;">
    <input type="hidden" id="filterFormBookmarkId" name="bookmarkId"/>
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
</form>
 -->

<script>
// CSRF 토큰 설정
var csrfToken = $('meta[name="_csrf"]').attr('content');
var csrfHeader = $('meta[name="_csrf_header"]').attr('content');

//0929 수정: 리뷰와 홍보 이미지를 처리하는 함수
function mediaImagesHtml(images, type) {
    var mediaImagesHtml = '';
    if (images && images.length > 0) {
        images.forEach(function(imagePath) {
            mediaImagesHtml += "<img src='" + imagePath + "' class='" + (type === 'review' ? 'review-image' : 'advertising-image') + "' onclick='showImageFullScreen(\"" + imagePath + "\")' title='" + (type === 'review' ? 'Review Image' : 'Advertising Image') + "'>";
        });
    } else {
        mediaImagesHtml = '<p>이미지가 없습니다.</p>';
    }
    return mediaImagesHtml;
}

//리뷰 HTML 생성 함수 수정
function generateReviewHtml(review) {
    return "<div id='reviewItem'>" +
            "<div id='reviewDetails'>" +
            "<div class='writer'>" + review.userName + " (" + review.userId + ")</div>" +
            "<h3>" + review.title + "</h3>" +
            "<br>" +
            "<div>" + review.content + "</div>" +
            "<div id='reviewImage'>" + mediaImagesHtml(review.images, 'review') + "</div>" +
            "</div>" +
            "<div id='reviewFooter'>" + 
            "<div id='likeSection'>" +
            "<img src='" + (review.liked ? "/images/like.png" : "/images/unlike.png") + "' " +
            "class='like-icon' " +
            "data-review-id='" + review.reviewId + "' " +  
            "data-liked='" + review.liked + "' " +
            "onclick='toggleReviewLike(event, this)' />" +
            " 좋아요: <span class='like-count'>" + review.likes + "</span>" +
            "</div>" +
            "<div id='ratingSection'>" +
            "<strong>별점:</strong> " + review.rating +
            "</div>" +
            "<div class='dateSection'>" +
            "<strong>작성일:</strong> " + review.createdDate +
            "</div>" +
            "</div>" +
            "</div>";
}

// 홍보 HTML 생성 함수 수정
function generateAdvertisingHtml(advertising) {
    return "<div id='advertisingItem'>" +
            "<div id='advertisingDetails'>" +
            "<div class='writer'>" + advertising.userName + " (" + advertising.userId + ")</div>" +
            "<h3>" + advertising.title + "</h3>" +
            "<br>" +
            "<div>" + advertising.content + "</div>" +
            "<div id='advertisingImage'>" + mediaImagesHtml(advertising.images, 'advertising') + "</div>" +
            "</div>" +
            "<div class='dateSection'>" +
            "<strong>작성일:</strong> " + advertising.createdDate +
            "</div>" +
            "</div>";
}

//0929추가: 리뷰 목록 갱신 함수
function updateReviewList(cafeId) {
    $.ajax({
        url: '/map/getCafeMedia',
        type: 'GET',
        data: { cafeId: cafeId },
        success: function(mediaItems) {
            var reviewListHtml = '';
            var advertisingListHtml = '';
            var imageGalleryHtml = ''; // 이미지 갤러리 초기화

            if (mediaItems.length > 0) {
                mediaItems.forEach(function(item) {
                    if (item.type === 'review') {
                        reviewListHtml += generateReviewHtml(item);
                    } else if (item.type === 'advertising') {
                        advertisingListHtml += generateAdvertisingHtml(item);
                    }

                    // 이미지 갤러리에 리뷰와 홍보 이미지를 모두 추가
                    item.images.forEach(function(imagePath) {
                        imageGalleryHtml += "<img src='" + imagePath + "' class='" + (item.type === 'review' ? 'review-image' : 'advertising-image') + "' onclick='showImageFullScreen(\"" + imagePath + "\")' title='" + (item.type === 'review' ? 'Review Image' : 'Advertising Image') + "'>";
                    });
                });
            } else {
                reviewListHtml = '<p style="text-align: center;">리뷰가 없습니다.</p>';
                advertisingListHtml = '<p style="text-align: center;">홍보가 없습니다.</p>';
                imageGalleryHtml = '<p style="text-align: center;">이미지가 없습니다.</p>';
            }

            document.getElementById('reviewList').innerHTML = reviewListHtml;
            document.getElementById('advertisingList').innerHTML = advertisingListHtml;
            document.getElementById('imageGallery').innerHTML = imageGalleryHtml;
        },
        error: function(err) {
            console.error("리뷰 목록 갱신 중 오류 발생: ", err);
        }
    });
}
////

//0911추가 - 외부 페이지에서 북마크 접근
    // bookmarkId가 존재하면, 해당 북마크의 세부 정보를 자동으로 요청합니다.
    <c:if test="${not empty bookmarkdetails2_bookmarkId}">
        var bookmarkId = "${bookmarkdetails2_bookmarkId}";
        // 페이지가 로드되면 자동으로 bookmarkId를 통해 북마크 정보를 가져옵니다.
        $(document).ready(function() {
            $.ajax({
                url: '/map/bookmarkdetails',
                type: 'POST',
                data: { bookmarkId: bookmarkId },
                beforeSend: function(xhr) {
                    xhr.setRequestHeader(csrfHeader, csrfToken); // CSRF 토큰을 헤더에 추가
                },
                success: function(response) {
                    // 북마크 정보 처리 및 모달 표시
                    var bookmark = {
                        title: response.bookmarkDetails.title,
                        content: response.bookmarkDetails.content,
                        userName: response.userName,
                        likes: response.bookmarkDetails.likes,
                        bookmarkId: response.bookmarkDetails.bookmarkId,
                        liked: response.bookmarkDetails.liked
                    };
                    showBookmarkDetailsModal(bookmark);
                    
                    // 로그인 여부에 따라 좋아요 버튼 처리
                    var loggedInUserId = response.loggedInUserId;
                    if (loggedInUserId) {
                        // 로그인한 사용자일 경우 좋아요 버튼 활성화
                        document.getElementById('bookmarkLikeButton').style.display = 'inline';
                    } else {
                        // 로그인하지 않은 경우 좋아요 버튼 비활성화
                        document.getElementById('bookmarkLikeButton').style.display = 'none';
                    }

                    // 카페 정보를 업데이트하는 로직 추가
                    updateMapWithCafes(response.cafeDetailsList);
                },
                error: function() {
                    alert('북마크 정보를 가져오는 중 오류가 발생했습니다.');
                }
            });
        });
    </c:if>

//0910 북마크 검색 (제목)
// 북마크 검색 Ajax
function searchBookmarks() {
    var searchKeyword = $('#bookmarkSearchInput').val();
    if (!searchKeyword) {
        alert('검색어를 입력해주세요.');
        return;
    }

    $.ajax({
        url: '/map/searchBookmarks',
        type: 'POST',
        data: {
            keyword: searchKeyword
        },
        beforeSend: function(xhr) {
            xhr.setRequestHeader(csrfHeader, csrfToken);
        },
        success: function(response) {
            console.log(response);
            var bookmarkListHtml = '';
            
            // 응답이 배열인지 확인
            if (Array.isArray(response) && response.length > 0) {
                response.forEach(function(bookmark) {
                    bookmarkListHtml += 
                        '<li class="bookmark-item" onclick="showCafesByBookmark(' + bookmark.bookmarkId + ')">' +
                            '<strong>북마크 제작자: ' + bookmark.userName + ' (' + bookmark.userId + ')</strong><br>' +
                            '제목: ' + bookmark.title + '<br>' +
                            '설명: ' + bookmark.content + '<br><br>' +
                            '<img src="' + (bookmark.liked ? '/images/like.png' : '/images/unlike.png') + '" ' +
                            'class="like-icon" ' +
                            'data-bookmark-id="' + bookmark.bookmarkId + '" ' +
                            'data-liked="' + bookmark.liked + '" ' +
                            'onclick="toggleBookmarkLike(event, this)" />' +
                            '<span class="like-count"> ' + bookmark.likes + '</span>' +
                        '</li>';
                });
            } else {
                bookmarkListHtml = '<p>검색 결과가 없습니다.</p>';
            }
            $('#bookmarkList').html(bookmarkListHtml);
        },
        error: function(error) {
            alert('북마크 검색 중 오류가 발생했습니다.');
        }
    });
}


// 북마크 선택 시 모달을 표시하도록 수정
window.showBookmarkDetailsModal = function(bookmark) {
    document.getElementById('bookmarkTitle').innerText = bookmark.title;
    document.getElementById('bookmarkContent').innerText = bookmark.content;
    document.getElementById('bookmarkUserName').innerText = bookmark.userName;
    document.getElementById('bookmarkLikes').innerText = bookmark.likes;

    // 좋아요 버튼에 데이터 설정
    const likeButton = document.getElementById('bookmarkLikeButton');
    likeButton.dataset.bookmarkId = bookmark.bookmarkId;
    likeButton.dataset.liked = bookmark.liked ? "true" : "false"; // bookmark.liked를 사용
    console.log("liked = " + bookmark.liked);

    // 처음 모달을 열 때 좋아요 상태를 확인해 아이콘 업데이트
    if (bookmark.liked) { // bookmark.liked를 사용
        likeButton.src = "/images/like.png";
    } else {
        likeButton.src = "/images/unlike.png";
    }

    // 모달 표시
    const modal = document.getElementById('bookmarkDetailsModal');
    modal.style.display = 'block';
    modal.style.visibility = 'visible';
};


//북마크를 선택했을 때만 showBookmarkDetailsModal을 호출하도록 합니다.
window.showCafesByBookmark = function(bookmarkId) {
    console.log("북마크 클릭함");
    $.ajax({
        url: '/map/bookmarkdetails',
        type: 'POST',
        data: { bookmarkId: bookmarkId },
        beforeSend: function(xhr) {
            xhr.setRequestHeader(csrfHeader, csrfToken); // CSRF 토큰을 헤더에 추가
        },
        success: function(response) {
            // 북마크 정보 처리 및 모달 표시
            // 북마크에 카페가 없는 경우 처리
            if (response.error === "noCafes") {
                alert("저장된 카페가 없습니다.");
                window.location.href = '/map/mapview'; // mapview로 리디렉션
                return;
            }
        	if (response.error) {
                console.error(response.error);
                return;
            }
            // 북마크 정보 처리 및 모달 표시
            var bookmark = {
                title: response.bookmarkDetails.title,
                content: response.bookmarkDetails.content,
                userName: response.userName,
                likes: response.bookmarkDetails.likes,
                bookmarkId: response.bookmarkDetails.bookmarkId,
                liked: response.liked // 서버에서 받아온 liked 값을 사용
            };
            showBookmarkDetailsModal(bookmark);
            
            // 로그인 여부에 따라 좋아요 버튼 처리
            var loggedInUserId = response.loggedInUserId;
            if (loggedInUserId) {
                document.getElementById('bookmarkLikeButton').style.display = 'inline';
            } else {
                document.getElementById('bookmarkLikeButton').style.display = 'none';
            }

            // 카페 정보를 업데이트하는 로직 추가
            updateMapWithCafes(response.cafeDetailsList);
        },
        error: function(error) {
            console.error('북마크 정보를 가져오는 중 오류가 발생했습니다.');
        }
    });
};

//0905 로딩 버퍼
//AJAX 요청 시작 시 로딩 이미지 표시
function showLoadingSpinner() {
    document.getElementById('loadingSpinner').style.display = 'block';
}
// AJAX 요청 완료 시 로딩 이미지 숨김
function hideLoadingSpinner() {
    document.getElementById('loadingSpinner').style.display = 'none';
}

$(document).ready(function() {
    $('#reviewForm').on('submit', function(event) {
        event.preventDefault(); // 기본 폼 제출 방지

        var formData = new FormData(this); // 폼 데이터를 수집합니다.
    	// AJAX 요청 전 로딩 이미지 표시
        showLoadingSpinner();

        $.ajax({
            url: $(this).attr('action'), // 폼의 action 속성을 사용하여 URL을 가져옵니다.
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            beforeSend: function(xhr) {
                xhr.setRequestHeader(csrfHeader, csrfToken); // CSRF 토큰을 헤더에 추가
            },
            success: function(response) {
            	hideLoadingSpinner(); // 완료 시 로딩 이미지 숨김
                if (response.success) {
                    alert(response.message); // 성공 메시지 표시
                    hideReviewModal(); // 리뷰 모달 닫기
                 	// 폼 리셋
                    $('#reviewForm')[0].reset(); 
                    
                    // 리뷰 작성 후 최신 리뷰 목록 불러오기
                    var cafeId = $('#reviewCafeId').val(); // 히든 필드에서 cafeId 가져옴
                    updateReviewList(cafeId); // 리뷰 목록 갱신 함수 호출
                    //홍보추간 다른 페이지에서 하니까 새로고침 안해도 됨
                } else {
                    alert(response.error); // 오류 메시지 표시
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
            	hideLoadingSpinner(); // 완료 시 로딩 이미지 숨김
                alert("리뷰 추가 중 오류가 발생했습니다: " + textStatus);
            }
        });
    });
});

// Bookmark 좋아요 토글 (0911 - 북마크 리스트와 북마크 상세정보에서 둘 다 동일 기능 수행하도록 변경)
function toggleBookmarkLike(event, element) {
    event.stopPropagation();
    
    showLoadingSpinner(); // 로딩 스피너 표시
    
    var bookmarkId = $(element).data('bookmark-id');
    var action = $(element).data('liked') === 'true' ? 'unlike' : 'like'; // `data-liked` 값에 따라 액션 결정

    $.ajax({
        url: '/map/bookmarklike',
        type: 'POST',
        data: {
            bookmarkId: bookmarkId,
            action: action
        },
        beforeSend: function(xhr) {
            xhr.setRequestHeader(csrfHeader, csrfToken);
        },
        success: function(response) {
            hideLoadingSpinner(); // 로딩 스피너 숨김
            
            if (response.error) {
                alert(response.error);
            } else {
                var isLiked = response.isLiked;
                var likesCount = response.likes;

                // 현재 클릭한 요소의 상태 업데이트
                $(element).data('liked', isLiked);
                $(element).attr('src', isLiked ? '/images/like.png' : '/images/unlike.png');  // 이미지 변경
                $(element).siblings('.like-count').text(likesCount);

                // bookmarkDetailsModal과 bookmarkList 모두 동기화
                syncBookmarkLikeStatus(bookmarkId, isLiked, likesCount);
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            hideLoadingSpinner(); // 로딩 스피너 숨김
            alert("오류가 발생했습니다: " + textStatus);
        }
    });
}

//bookmarkList와 bookmarkDetailsModal 좋아요 상태 동기화
function syncBookmarkLikeStatus(bookmarkId, isLiked, likesCount) {
    // bookmarkDetailsModal 동기화
    var modalLikeButton = document.getElementById('bookmarkLikeButton');
    if (modalLikeButton && modalLikeButton.dataset.bookmarkId == bookmarkId) {
        modalLikeButton.dataset.liked = isLiked ? "true" : "false";
        modalLikeButton.src = isLiked ? "/images/like.png" : "/images/unlike.png";
        document.getElementById('bookmarkLikes').innerText = likesCount;
    }

    // bookmarkList의 좋아요 상태 동기화
    var listLikeButton = $('img[data-bookmark-id="' + bookmarkId + '"]');
    listLikeButton.each(function() {
        $(this).data('liked', isLiked);
        $(this).attr('src', isLiked ? '/images/like.png' : '/images/unlike.png');
        $(this).siblings('.like-count').text(likesCount);
    });
}

// Review 좋아요 토글
function toggleReviewLike(event, element) {
    event.stopPropagation();
	// AJAX 요청 전 로딩 이미지 표시
    showLoadingSpinner();

    var reviewId = $(element).data('review-id');
    var action = $(element).data('liked') === 'true' ? 'unlike' : 'like';

    $.ajax({
        url: '/map/reviewlike',
        type: 'POST',
        data: {
            reviewId: reviewId,
            action: action
        },
        beforeSend: function(xhr) {
            xhr.setRequestHeader(csrfHeader, csrfToken);
        },
        success: function(response) {
        	hideLoadingSpinner(); // 완료 시 로딩 이미지 숨김
            if (response.error) {
                alert(response.error);
            } else {
                $(element).data('liked', response.isLiked);
                $(element).attr('data-liked', response.isLiked);
                $(element).attr('src', response.isLiked ? '/images/like.png' : '/images/unlike.png');
                $(element).siblings('.like-count').text(response.likes);
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
        	hideLoadingSpinner(); // 완료 시 로딩 이미지 숨김
            alert("오류가 발생했습니다: " + textStatus);
        }
    });
}

//현재 위치 이동 함수 - POST 방식으로 좌표를 전송
function moveToCurrentLocation() {
	//로딩 시작
	showLoadingSpinner();
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
            var latitude = position.coords.latitude;
            var longitude = position.coords.longitude;

            // 동적으로 폼 생성하여 POST 방식으로 좌표 전송
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = '/map/searchNearbyCafes';

            // CSRF 토큰이 있다면 폼에 추가
            var csrfToken = document.querySelector('meta[name="_csrf"]').getAttribute('content');
            var csrfInput = document.createElement('input');
            csrfInput.type = 'hidden';
            csrfInput.name = '_csrf';
            csrfInput.value = csrfToken;
            form.appendChild(csrfInput);

            // 위도, 경도 값을 폼에 추가
            var latitudeInput = document.createElement('input');
            latitudeInput.type = 'hidden';
            latitudeInput.name = 'y';
            latitudeInput.value = latitude;
            form.appendChild(latitudeInput);

            var longitudeInput = document.createElement('input');
            longitudeInput.type = 'hidden';
            longitudeInput.name = 'x';
            longitudeInput.value = longitude;
            form.appendChild(longitudeInput);

            // 폼을 document에 추가하고 제출
            document.body.appendChild(form);
            form.submit();

        }, function(error) {
            console.error('현재 위치를 가져오는 중 오류 발생:', error);
            alert('현재 위치를 가져올 수 없습니다.');
        });
    } else {
        alert('Geolocation을 지원하지 않는 브라우저입니다.');
    }
    //로딩 끝
    hideLoadingSpinner();
}

window.onload = function() {
	
	var mapContainer = document.getElementById('map'),
    mapOption = { 
        center: new kakao.maps.LatLng(37.556008, 126.972341),
        level: 3
    };

    var map = new kakao.maps.Map(mapContainer, mapOption);

    var markers = [];
    var selectedCafes = new Set();
    var cafeDetailsList = [];
    var isBookmarkModalOpen = false; // 북마크 모달이 열렸는지 여부

    <c:if test="${not empty cafeDetailsList}">
        var bounds = new kakao.maps.LatLngBounds();
        cafeDetailsList = [
            <c:forEach var="cafe" items="${cafeDetailsList}" varStatus="status">
                {
                    cafeId: '${cafe.cafeId}',
                    x: '${cafe.x}',
                    y: '${cafe.y}',
                    placeName: '${cafe.placeName}',
                    addressName: '${cafe.addressName}',
                    roadAddressName: '${cafe.roadAddressName}',
                    phone: '${cafe.phone}',
                    placeUrl: '${cafe.placeUrl}'
                }<c:if test="${!status.last}">,</c:if>
            </c:forEach>
        ];

        cafeDetailsList.forEach(function(cafe, index) {
            var latlng = new kakao.maps.LatLng(cafe.y, cafe.x);
            bounds.extend(latlng);

            var marker = new kakao.maps.Marker({
                map: map,
                position: latlng,
                title: cafe.placeName
            });
			// 마커 클릭 이벤트 추가 - 클로저 사용
            (function(marker, cafe) {
                kakao.maps.event.addListener(marker, 'click', function() {
                    console.log("마커 클릭됨: ", marker); // 마커 디버그 정보 출력
                    //console.log("카페 정보: ", cafe); // 카페 정보 디버그 출력
                    map.panTo(marker.getPosition());
                    showCafeInfoModal(cafe);
                });
            })(marker, cafe);

            markers.push(marker);
        });

        map.setBounds(bounds);
    </c:if>
	//0929지도초기화 다 됐으면 현재 위치 보일지 말지 처리
	// 세션에 현재 위치 정보가 있을 때만 빨간 마커를 표시
    <c:if test="${not empty currentLocation}">
        var currentLocation = new kakao.maps.LatLng(${currentLocation.y}, ${currentLocation.x});

        // 현재 위치를 빨간 마커로 표시
        var imageSize = new kakao.maps.Size(34, 51);
        var imageOption = { offset: new kakao.maps.Point(27, 69) };
        var markerImage = new kakao.maps.MarkerImage('/images/mapview/location/currentLocationMarker.png', imageSize, imageOption);
        var currentLocationMarker = new kakao.maps.Marker({
            map: map,
            position: currentLocation,
            image: markerImage
        });

        // 지도 중심을 현재 위치로 이동
        map.setCenter(currentLocation);
    </c:if>
	
    //전역변수
    var currentInfowindow = null; // 현재 열린 인포윈도우를 저장할 변수
    window.moveToMarker = function(index) {
        var position = markers[index].getPosition();
        map.panTo(position);

         // 해당 마커의 인포윈도우 열기
        var iwContent = '<div style="padding:5px; margin-left: 40px" id="infoWindow">' + 
            '여기에요!' + '</div>';

        var infowindow = new kakao.maps.InfoWindow({
            content: iwContent,
            removable: true // X 버튼을 표시하기 위해 true 설정
        });

        // 이전 인포윈도우가 열려 있으면 닫기
        if (currentInfowindow) {
            currentInfowindow.close();
        }

        // 현재 인포윈도우를 저장
        currentInfowindow = infowindow;

         // 일정 시간 후에 인포윈도우 열기
        setTimeout(function() {
            infowindow.open(map, markers[index]); // 인포윈도우 열기
        }, 200); // 200ms 후에 인포윈도우 열기
    };
	
    window.showBookmarkListModal = function() {
        document.getElementById('bookmarkListModal').style.display = 'block';
    };
    
    window.hideBookmarkDetailsModal = function() {
        document.getElementById('bookmarkDetailsModal').style.display = 'none';
    };
    
	// 0902 추가 - 카페에 등록된 리뷰 홍보들과 이미지 보이기
	window.showCafeInfoModal = function(cafe) {
    	// AJAX 요청 전 로딩 이미지 표시
        showLoadingSpinner();
    	
	    console.log("마커를 선택했습니다");
	    var cafeModal = document.getElementById('cafeInfoModal'); 
	    
	    // 0926 카페 정보 모달 창 애니메이션 추가 (opacity 초기화 및 디스플레이 설정)
	    cafeModal.style.display = 'block';
	    cafeModal.style.opacity = '0'; // 초기 투명도 설정

	    // 부드럽게 열기 애니메이션
	    requestAnimationFrame(() => {
	        cafeModal.style.transition = 'opacity 1s ease'; // 애니메이션 효과 추가
	        cafeModal.style.opacity = '1'; // 투명도 변경
	    });

	    
	    //console.log("카페 데이터 확인: ", cafe); // 디버깅용 로그 
	    
	    
		// 기존 카페 정보 설정
	    var cafeInfoContent = 
	        /* "<strong>카페명: </strong> " + cafe.placeName + "<br>" + */
	        "<strong>지번주소: </strong> " + cafe.addressName + "<br>" +
	        "<strong>도로명주소: </strong> " + cafe.roadAddressName + "<br>" +
	        "<strong>전화번호: </strong> " + cafe.phone + "<br><br>" +
	        "<a id='kakaoMap' href='" + cafe.placeUrl + "' target='_blank'>카카오 맵에서 보기</a>";
	        
		// cafeInfoTitle 요소에 카페명을 설정
        document.getElementById('cafeInfoTitle').innerText = cafe.placeName;

	    document.getElementById('cafeInfoContent').innerHTML = cafeInfoContent;
	    
	 	// 리뷰 작성 시 필요한 정보를 히든 필드에 설정
	    document.getElementById('reviewCafeId').value = cafe.cafeId;
	    document.getElementById('reviewCafeX').value = cafe.x;
	    document.getElementById('reviewCafeY').value = cafe.y;
	    document.getElementById('reviewCafeName').value = cafe.placeName;
	    
	    // 서버에서 최신 리뷰와 홍보 정보를 가져옴
	    $.ajax({
	        url: '/map/getCafeMedia',
	        type: 'GET',
	        data: { cafeId: cafe.cafeId },
	        success: function(mediaItems) {
	        	hideLoadingSpinner(); // 완료 시 로딩 이미지 숨김
	            var reviewListHtml = '';
	            var advertisingListHtml = '';
	            var imageGalleryHtml = '';

	            if (mediaItems.length > 0) {
	                mediaItems.forEach(function(item) {
	                    if (item.type === 'review') {
	                        reviewListHtml += generateReviewHtml(item);
	                    } else if (item.type === 'advertising') {
	                        advertisingListHtml += generateAdvertisingHtml(item);
	                    }

	                    item.images.forEach(function(imagePath) {
	                        imageGalleryHtml += "<img src='" + imagePath + "' class='review-image' onclick='showImageFullScreen(\"" + imagePath + "\")' title='" + (item.type === 'review' ? 'Review Image' : 'Advertising Image') + "'>";
	                    });
	                });
	            } else {
	                reviewListHtml = '<p style="text-align: center;">리뷰가 없습니다.</p>';
	                advertisingListHtml = '<p style="text-align: center;">홍보가 없습니다.</p>';
	            }

	            document.getElementById('reviewList').innerHTML = reviewListHtml;
	            document.getElementById('advertisingList').innerHTML = advertisingListHtml;
	            document.getElementById('imageGallery').innerHTML = imageGalleryHtml;
	        },
	        error: function(err) {
	        	hideLoadingSpinner(); // 완료 시 로딩 이미지 숨김
	            console.error("미디어 로딩 중 오류 발생: ", err);
	        }
	    });
	};
	
	
	
	
	// 홍보 추가 페이지로 리다이렉트
	window.redirectToAdvertisingPage = function() {
	    alert("마이페이지에서 카페를 등록하여 홍보를 작성해주세요");
	    window.location.href = '/user/home';
	};
	
	
	// 리뷰랑 홍보 item 작성하는 메서드
	function generateReviewHtml(review) {
	    console.log("review html create - review:" + review);
	    return  "<div id='reviewItem'>" +
					"<div id='reviewDetails'>" +
						"<div class='writer'>" + review.userName + " (" + review.userId + ")</div>" +
						"<h3>" + review.title + "</h3>" +
						"<br>" +
						"<div>" + review.content + "</div>" +
						"<div id='reviewImage'>" + reviewImagesHtml(review.images) + "</div>" +
					"</div>" +
					"<div id='reviewFooter'>" + 
						"<div id='likeSection'>" +
							"<img src='" + (review.liked ? "/images/like.png" : "/images/unlike.png") + "' " +
							"class='like-icon' " +
							"data-review-id='" + review.reviewId + "' " +  // reviewId가 제대로 설정되었는지 확인
							"data-liked='" + review.liked + "' " +
							"onclick='toggleReviewLike(event, this)' />" +
							" 좋아요: <span class='like-count'>" + review.likes + "</span>" +
						"</div>" +
						"<div id='ratingSection'>" +
							"<strong>별점:</strong> " + review.rating +
						"</div>" +
						"<div class='dateSection'>" +
							"<strong>작성일:</strong> " + review.createdDate +
						"</div>" +
					"</div>" +
				"</div>";

	}
	
	
	function generateAdvertisingHtml(advertising) {
	    return  "<div id='advertisingItem'>" +
	    			"<div id='advertisingDetails'>" +
						"<div class='writer'>" + advertising.userName + " (" + advertising.userId + ")" + "</div>" +
						"<h3>" + advertising.title + "</h3>" + 
						"<br>" +
						"<div>" + advertising.content + "</div>" +
						"<div id='advertisingImage'>" + advertisingImagesHtml(advertising.images) + "</div>" +
					"</div>" +
					"<div class='dateSection'>" + 
						"<strong>작성일:</strong> " + advertising.createdDate + 
					"</div>" +
				"</div>";
	}
	
	
	
	function reviewImagesHtml(images) {
	    var reviewImagesHtml = '';
	    if (images && images.length > 0) {
	        images.forEach(function(imagePath) {
	            reviewImagesHtml += "<img src='" + imagePath + "' class='review-image' onclick='showImageFullScreen(\"" + imagePath + "\")' title='Review Image'>";
	        });
	    } else {
	        reviewImagesHtml = '<p>이미지가 없습니다.</p>';
	    }
	    return reviewImagesHtml;
	}
	
	
	
	function advertisingImagesHtml(images) {
	    var advertisingImagesHtml = '';
	    if (images && images.length > 0) {
	        images.forEach(function(imagePath) {
	            advertisingImagesHtml += "<img src='" + imagePath + "' class='advertising-image' onclick='showImageFullScreen(\"" + imagePath + "\")' title='Advertising Image' style='max-width: 200px; max-height: 150px;'>";
	        });
	    } else {
	        advertisingImagesHtml = '<p>이미지가 없습니다.</p>';
	    }
	    return advertisingImagesHtml;
	}
	
    // 0828 추가 리뷰의 이미지 크게 보이기
    // 이미지를 전체 화면으로 표시하는 함수 추가
	function showImageFullScreen(imagePath) {
	    // 전체 화면 표시 로직을 여기에 작성합니다.
	    // 예를 들어, 새 창에서 이미지를 표시하거나 모달 창을 사용할 수 있습니다.
	    var modal = document.createElement('div');
	    modal.style.position = 'fixed';
	    modal.style.top = 0;
	    modal.style.left = 0;
	    modal.style.width = '100%';
	    modal.style.height = '100%';
	    modal.style.backgroundColor = 'rgba(0,0,0,0.8)';
	    modal.style.display = 'flex';
	    modal.style.alignItems = 'center';
	    modal.style.justifyContent = 'center';
	    modal.style.zIndex = 9999;
	
	    var img = document.createElement('img');
	    img.src = imagePath;
	    img.style.maxWidth = '90%';
	    img.style.maxHeight = '90%';
	    img.style.cursor = 'pointer';
	
	    modal.onclick = function () {
	        document.body.removeChild(modal);
	    };
	
	    modal.appendChild(img);
	    document.body.appendChild(modal);
	}

    // 0926 카페 정보 모달 닫기 애니메이션 추가
    window.hideCafeInfoModal = function() {
        /* document.getElementById('cafeInfoModal').style.display = 'none'; */
		var cafeModal = document.getElementById('cafeInfoModal');
		cafeModal.style.transition = 'opacity 1s ease'; // 애니메이션 효과 추가
		cafeModal.style.opacity = '0'; // 서서히 투명하게 만들기
        
		// 애니메이션이 완료된 후 display를 none으로 설정
	    cafeModal.addEventListener('transitionend', function() {
	        cafeModal.style.display = 'none';
	    }, { once: true }); // 한번만 이벤트 리스너 실행
    };

    window.showReviewModal = function() {
        document.getElementById('reviewModal').style.display = 'block';
    };

    // 0926 리뷰 모달 창 애니메이션 추가
    window.hideReviewModal = function() {
        /* document.getElementById('reviewModal').style.display = 'none'; */
    	const modal = document.getElementById('reviewModal');
    	modal.style.animation = 'modalHide 0.3s ease-out forwards'; /* 모달 닫는 애니메이션 */
    	
    	// 애니메이션이 끝난 후 모달을 숨기고 애니메이션 초기화
        setTimeout(() => {
            modal.style.display = 'none'; /* 애니메이션 종료 후 모달 숨김 */
            modal.style.animation = '';    /* 애니메이션 속성 초기화 */
        }, 300); // 애니메이션 지속 시간 후에 모달 숨기기
    };

    window.toggleCafeSelection = function(index) {
        if (!isBookmarkModalOpen) {
        	// 북마크 모달이 열리지 않은 상태에서는 아무것도 하지 않음
            return;
        }

        if (selectedCafes.has(index)) {
            selectedCafes.delete(index);
            document.querySelectorAll('.cafe-item')[index].classList.remove('selected');
        } else {
            selectedCafes.add(index);
            document.querySelectorAll('.cafe-item')[index].classList.add('selected');
        }
    };

    document.getElementById('bookmarkForm').onsubmit = function() {
        var selectedCafeDetails = [];
        selectedCafes.forEach(function(index) {
            selectedCafeDetails.push({
                cafeId: cafeDetailsList[index].cafeId,
                x: cafeDetailsList[index].x,
                y: cafeDetailsList[index].y,
                placeName: cafeDetailsList[index].placeName
            });
        });

        document.getElementById('selectedCafesInput').value = JSON.stringify(selectedCafeDetails);
        return true;
    };
	
    //0929 수정 - 현재 위치 검색 -> 변경함, onload 바깥 확인
	//window.moveToCurrentLocation = function() {}
    /* 홈버튼 이동 함수 */
    window.movetoIndex = function() {
    	/* 홈버튼 경로 지정 : index.html 통합 되면 경로 수정 필요 */
    	location.href='/';
    }

    /* 0910 이전의 북마크 검색 방법
    window.showCafesByBookmark = function(bookmarkId) {
        document.getElementById('filterFormBookmarkId').value = bookmarkId;
        document.getElementById('filterForm').submit();
    };
    */
	
    //0911-북마크 안의 카페들을 보여주는 메서드
	//function updateMapWithCafes(cafeDetailsList) {
    window.updateMapWithCafes = function(cafeDetailsList) {
        // 카페 객체의 속성 이름을 카멜 케이스로 통일
        cafeDetailsList = cafeDetailsList.map(function(cafe) {
            return {
                cafeId: cafe.cafeId || cafe.id,
                x: cafe.x,
                y: cafe.y,
                placeName: cafe.placeName || cafe.place_name,
                addressName: cafe.addressName || cafe.address_name,
                roadAddressName: cafe.roadAddressName || cafe.road_address_name,
                phone: cafe.phone,
                placeUrl: cafe.placeUrl || cafe.place_url
            };
        });

        // 기존 마커 제거
        markers.forEach(marker => marker.setMap(null));
        markers = [];

        var bounds = new kakao.maps.LatLngBounds();

        // 카페 정보로 마커 생성
        cafeDetailsList.forEach(function(cafe, index) {
            var latlng = new kakao.maps.LatLng(cafe.y, cafe.x);
            bounds.extend(latlng);

            var marker = new kakao.maps.Marker({
                map: map,
                position: latlng,
                title: cafe.placeName
            });

            // 마커 클릭 시 카페 정보를 모달에 표시
            (function(marker, cafe) {
                kakao.maps.event.addListener(marker, 'click', function() {
                    map.panTo(marker.getPosition());
                    showCafeInfoModal(cafe);
                });
            })(marker, cafe);

            markers.push(marker);
        });

        // 지도에 모든 마커가 보이도록 설정
        map.setBounds(bounds);

        // 검색 결과 리스트 업데이트
        var listForm = document.getElementById('listForm');
        var listHtml = cafeDetailsList.map(function(cafe, index) {
            return '<li class="cafe-item" onclick="moveToMarker(' + index + '); toggleCafeSelection(' + index + ');">' +
                       '<strong id="placeName">' + cafe.placeName + '</strong><br>' +
                       '주소: ' + cafe.addressName + '<br>' +
                       '전화번호: ' + (cafe.phone || '없음') + '<br>' +
                       '<a href="' + cafe.placeUrl + '" target="_blank">자세히 보기</a>' +
                   '</li>';
        }).join('');

        listForm.innerHTML = '<ul style="list-style: none; padding: 0;">' + listHtml + '</ul>';
    };
    
    
    
    
	/*
    function updateMapWithCafes(cafes) {
        markers.forEach(marker => marker.setMap(null));
        markers = [];
        var bounds = new kakao.maps.LatLngBounds();

        cafes.forEach((cafe, index) => {
            var latlng = new kakao.maps.LatLng(cafe.y, cafe.x);
            var marker = new kakao.maps.Marker({
                map: map,
                position: latlng,
                title: cafe.placeName
            });
            
            (function(marker, cafe) {
                kakao.maps.event.addListener(marker, 'click', function() {
                    map.panTo(marker.getPosition());
                    showCafeInfoModal(cafe);
                });
            })(marker, cafe);

            markers.push(marker);
            bounds.extend(latlng);
        });

        map.setBounds(bounds);

        var listForm = document.getElementById('listForm');
        var listHtml = cafes.map(function(cafe, index) {
            return `
                <li class="cafe-item" onclick="moveToMarker(${index}); toggleCafeSelection(${index});">
                    <strong>${cafe.placeName}</strong><br>
                    주소: ${cafe.addressName}<br>
                    전화번호: ${cafe.phone}<br>
                    <a href="${cafe.placeUrl}" target="_blank">자세히 보기</a>
                </li>
            `;
        }).join('');
        listForm.innerHTML = `<ul style="list-style: none; padding: 0;">${listHtml}</ul>`;
    }
    */
    
    
    /* 북마크 모달 열기 */
    window.showBookmarkCreateModal = function() {
        selectedCafes.clear(); // 북마크 모달 열 때 selectedCafes 초기화
        document.getElementById('bookmarkCreateModal').style.display = 'block';
        isBookmarkModalOpen = true;
    };

    
    /* x버튼을 눌러서 북마크 생성 팝업 닫기(~0919) -> 기능을 버튼에서 온오프 하도록 변경 (0919~) */
    window.hideBookmarkCreateModal = function() {
        
    	// 애니메이션 구동 시 $(this).css('display', 'none');와 겹쳐서 주석처리
    	// document.getElementById('bookmarkCreateModal').style.display = 'none';
    	
        isBookmarkModalOpen = false;
        selectedCafes.clear(); // 북마크 모달 닫을 때 selectedCafes 초기화
        // 선택된 li 요소들의 회색 배경 초기화
        document.querySelectorAll('.cafe-item.selected').forEach(function(item) {
            item.classList.remove('selected');
        });
    };
    
    
    
    // 0919 북마크 생성 모달을 열고, 닫는 기능 + 각각의 이벤트에 따라 이미지가 변경되는 함수 + 툴팁 변경
    $(document).ready(function() {
        var isCreateBookmarkModalVisible = false;

        $('#createBookmarkButton').click(function() {
            if (isCreateBookmarkModalVisible) {
            	
				// 북마크 닫는 함수 실행
            	hideBookmarkCreateModal();
            	
                // 북마크 생성 모달 닫기 (위로 올라가는 애니메이션)
                $('#bookmarkCreateModal').animate({ top: '-100%' }, 300, function() {
                	 $(this).css('display', 'none'); // 애니메이션 후 display를 none으로 설정
                });
                
                // 버튼 이미지 변경
                $('#createBookmarkButtonImage').attr('src', '/images/mapview/bookmark/createbookmark.png');

                // 툴팁 텍스트 변경
                $('#createBookmarkButtonTooltip').attr('title', '북마크 생성하기');
                
            } else {
            	
            	// 북마크 여는 함수 실행
            	showBookmarkCreateModal();
            	
            	// 북마크 생성 모달 열기 (아래로 내려오는 애니메이션)
                $('#bookmarkCreateModal').css('top', '-100%').show().animate({ top: '4px' }, 300);

                // 버튼 이미지 변경
                $('#createBookmarkButtonImage').attr('src', '/images/mapview/bookmark/onclickCreatebookmark.png');

                // 툴팁 텍스트 변경
                $('#createBookmarkButtonTooltip').attr('title', '북마크 생성 취소하기');
                
            }

            isCreateBookmarkModalVisible = !isCreateBookmarkModalVisible;
        });
    });


    
    
};



// X 버튼 클릭 시 검색창을 비우고 검색 결과 리스트를 닫는 함수입니다.
function clearSearch() {
	// 검색창에 입력된 내용을 지움
	document.getElementById('keywordInput').value = '';
	
	// 검색 결과 영역을 비우거나 숨김
	const listForm = document.getElementById('listForm');
	listForm.innerHTML = '';
}



// 검색창 사이드바를 숨기거나, 다시 표시하는 버튼의 함수 
const searchListForm = document.getElementById('searchListForm');
const hideFormbutton = document.getElementById('hideFormbutton');

let isFormHidden = false;

hideFormbutton.addEventListener('click', function() {
    if (isFormHidden) {
        // 사이드 바를 우측으로 표시
        searchListForm.style.left = '0';
        
        // 버튼을 우측으로 이동시키고 이미지를 변경
        hideFormbutton.style.left = '364px'; // 원래 위치로 돌아옴
        hideFormbutton.querySelector('img').src = '/images/mapview/form/hideForm.png';
        
        isFormHidden = false;
    } else {
        // 사이드 바를 좌측으로 숨김
        searchListForm.style.left = '-370px';
        
        // 버튼을 좌측 끝으로 이동시키고 이미지를 변경
        hideFormbutton.style.left = '-6px'; // 우측으로 이동
        hideFormbutton.querySelector('img').src = '/images/mapview/form/showForm.png';
        
        isFormHidden = true;
    }
});



// 북마크를 열고, 닫는 기능 + 각각의 이벤트에 따라 이미지가 변경되는 함수
$(document).ready(function() {
    var isBookmarkListVisible = false;

    $('#bookmarkListButton').click(function() {
        if (isBookmarkListVisible) {
            // 북마크 리스트 모달 닫기 (위로 올라가는 애니메이션)
            $('#bookmarkListModal').animate({ top: '-100%' }, 300, function() {
                $(this).hide(); // 애니메이션이 끝나면 display를 none으로 설정
            });

            // 버튼 이미지 변경
            $('#bookmarkButtonImage').attr('src', '/images/mapview/bookmark/bookmark.png');
            
         	// 툴팁 텍스트 변경
            $('#bookmarkTooltip').attr('title', '북마크 리스트 열기');
        } else {
            // 북마크 리스트 모달 열기 (아래로 내려오는 애니메이션)
            $('#bookmarkListModal').show().animate({ top: '80px' }, 300);

            // 버튼 이미지 변경
            $('#bookmarkButtonImage').attr('src', '/images/mapview/bookmark/onclickShowbookmark.png');
            
         // 툴팁 텍스트 변경
            $('#bookmarkTooltip').attr('title', '북마크 리스트 닫기');
        }

        isBookmarkListVisible = !isBookmarkListVisible;
    });
});





// 북마크 생성 모달의 내부 STEP(div) 이벤트 및 애니메이션 처리
const prevButton = document.getElementById('prevButton');
const nextButton = document.getElementById('nextButton');
const submitButton = document.getElementById('submitButton');
const steps = document.querySelectorAll('.step');

let currentStep = 0; // 현재 단계 인덱스 초기화

// 다음 버튼 위치 조정
function adjustNextButtonPosition(stepIndex) {
    if (stepIndex === 0) {
        nextButton.style.position = 'relative'; // 상대 위치 설정
        nextButton.style.right = '0';
        nextButton.style.marginLeft = 'auto'; 
    } else {
        nextButton.style.position = 'static'; // 정적 위치 설정
        nextButton.style.marginLeft = '0'; 
    }
}

// 현재 단계 표시
function showStep(stepIndex) {
    steps.forEach((step, index) => {
        if (index === stepIndex) {
            step.classList.add('active'); // 현재 단계 활성화
            step.classList.remove('slide-out', 'slide-in'); // 슬라이드 효과 제거
        } else {
            step.classList.remove('active', 'slide-in'); // 비활성 단계 처리
        }
    });

    // 이전 버튼 표시 여부
    prevButton.style.display = stepIndex > 0 ? 'inline-block' : 'none';

    // 마지막 단계에서 버튼 표시 조정
    if (stepIndex === steps.length - 1) {
        nextButton.style.display = 'none';
        submitButton.style.display = 'inline-block'; // 제출 버튼 표시
    } else {
        nextButton.style.display = 'inline-block'; // 다음 버튼 표시
        submitButton.style.display = 'none'; // 제출 버튼 숨김
    }

    adjustNextButtonPosition(stepIndex); // 버튼 위치 조정 함수 호출
}

// 다음 버튼 클릭 이벤트 처리
nextButton.addEventListener('click', () => {
    steps[currentStep].classList.add('slide-out'); // 현재 단계 슬라이드 아웃
    currentStep++; // 단계 증가
    if (currentStep < steps.length) {
        setTimeout(() => {
            showStep(currentStep); // 다음 단계 표시
            steps[currentStep].classList.remove('slide-out');
            steps[currentStep].classList.add('slide-in'); // 다음 단계 슬라이드 인
        }, 500); // 애니메이션 시간 설정
    }
});

// 이전 버튼 클릭 이벤트 처리
prevButton.addEventListener('click', () => {
    steps[currentStep].classList.add('slide-in'); // 현재 단계 슬라이드 인
    currentStep--; // 단계 감소
    if (currentStep >= 0) {
        setTimeout(() => {
            showStep(currentStep); // 이전 단계 표시
            steps[currentStep].classList.remove('slide-in');
            steps[currentStep].classList.add('active'); // 이전 단계 활성화
        }, 500); // 애니메이션 시간 설정
    }
});

showStep(currentStep); // 초기 단계 표시

//0930 추가 모달 닫기
document.addEventListener('keydown', function(event) {
    // ESC 키가 눌렸을 때
    if (event.key === 'Escape') {
        window.hideCafeInfoModal();
    }
});
</script>

</body>
</html>