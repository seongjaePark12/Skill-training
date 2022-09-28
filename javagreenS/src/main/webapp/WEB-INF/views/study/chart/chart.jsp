<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<% pageContext.setAttribute("newLine", "\n"); %>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>chart.jsp</title>
  <%@ include file="/WEB-INF/views/include/bs4.jsp" %>
  <script>
    function chartChange() {
    	var part = document.getElementById("part").value;
    	location.href='${ctp}/study/googleChart?part='+part;
    }
  </script>
</head>
<body>
<%@ include file="/WEB-INF/views/include/nav.jsp" %>
<%@ include file="/WEB-INF/views/include/slide2.jsp" %>
<p><br/></p>
<div class="container">
  <h2>구글 차트 연습</h2>
  <div>
    <p>학습할 차트 선택하세요..
      <select name="part" id="part" onchange="chartChange()">
        <option value="">차트선택</option>
        <option value="barV" ${part == 'barV' ? 'selected' : ''}>수직막대차트</option>
        <option value="barH" ${part == 'barH' ? 'selected' : ''}>수평막대차트</option>
        <option value="line" ${part == 'line' ? 'selected' : ''}>꺽은선차트</option>
        <option value="pie" ${part == 'pie' ? 'selected' : ''}>원형차트</option>
        <option value="pie3D" ${part == 'pie3D' ? 'selected' : ''}>3D원형차트</option>
        <option value="pieDonut" ${part == 'pieDonut' ? 'selected' : ''}>도우넛차트</option>
        <option value="bubble" ${part == 'bubble' ? 'selected' : ''}>버블차트</option>
        <option value="combo" ${part == 'combo' ? 'selected' : ''}>콤보차트</option>
        <option value="timeline" ${part == 'timeline' ? 'selected' : ''}>Timelines</option>
      </select>
    </p>
    <hr/>
    <div>
      <c:if test="${part == 'barV'}"><jsp:include page="barVChart.jsp"/></c:if>
      <c:if test="${part == 'barH'}"><jsp:include page="barHChart.jsp"/></c:if>
      <c:if test="${part == 'line'}"><jsp:include page="lineChart.jsp"/></c:if>
      <c:if test="${part == 'pie'}"><jsp:include page="pieChart.jsp"/></c:if>
      <c:if test="${part == 'pie3D'}"><jsp:include page="pie3DChart.jsp"/></c:if>
      <c:if test="${part == 'pieDonut'}"><jsp:include page="pieDonutChart.jsp"/></c:if>
      <c:if test="${part == 'bubble'}"><jsp:include page="bubbleChart.jsp"/></c:if>
      <c:if test="${part == 'combo'}"><jsp:include page="comboChart.jsp"/></c:if>
      <c:if test="${part == 'timeline'}"><jsp:include page="timelineChart.jsp"/></c:if>
    </div>
    <hr/>
  </div>
</div>
<p><br/></p>
<%@ include file="/WEB-INF/views/include/footer.jsp" %>
</body>
</html>