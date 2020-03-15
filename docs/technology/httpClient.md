# HttpClient常见请求与传参方式
<p style="text-indent:2em">
每次在代码中调用第三方接口时，都要百度传参方式，索性一次性整理出来，方便查找
</p>


## `GET` 请求
<p style="text-indent:2em">
get请求最简单，就是在url上拼接参数即可，如果不想手动拼接参数，可以使用以下API
</p>

使用`URIBuilder`构建URL，`URIBuilder`有两种拼接方式`addParameter`，`NameValuePair`
```java
private String get() throws URISyntaxException, IOException {
        HttpClient httpClient = HttpClients.createDefault();
        URIBuilder url = new URIBuilder("http://127.0.0.1/api/open/test/get");

        url.addParameter("a","123");

        List<NameValuePair> list = new ArrayList<>();
        list.add(new BasicNameValuePair("b","456"));
        url.addParameters(list);

        HttpGet httpGet = new HttpGet(url.build());
        HttpResponse response = httpClient.execute(httpGet);
        int code = response.getStatusLine().getStatusCode();
        if (code == HttpServletResponse.SC_OK) {
            return EntityUtils.toString(response.getEntity());
        }
        return null;
}
```

## `POST` 请求体传参

```java
private String postByBody() throws IOException {
        HttpClient httpClient = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost("http://127.0.0.1/api/open/test/post/body");
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("a","123");
        jsonObject.put("b","456");
        httpPost.setHeader(new BasicHeader("Content-Type","application/json;charset=UTF-8"));
        httpPost.setEntity(new StringEntity(jsonObject.toString()));
        HttpResponse response = httpClient.execute(httpPost);
        int code = response.getStatusLine().getStatusCode();
        if (code == HttpServletResponse.SC_OK) {
            return EntityUtils.toString(response.getEntity());
        }
        return null;
}
```

## `POST` 表单传参

```java
private String postByForm() throws IOException {
        HttpClient httpClient = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost("http://127.0.0.1/api/open/test/post/param");
        List<NameValuePair> list = new ArrayList<>();
        list.add(new BasicNameValuePair("a","123"));
        list.add(new BasicNameValuePair("b","456"));
        httpPost.setHeader(new BasicHeader("Content-Type","application/x-www-form-urlencoded"));
        httpPost.setEntity(new UrlEncodedFormEntity(list,"UTF-8"));
        HttpResponse response = httpClient.execute(httpPost);
        int code = response.getStatusLine().getStatusCode();
        if (code == HttpServletResponse.SC_OK) {
            return EntityUtils.toString(response.getEntity());
        }
}
```

## `POST` 文件上传
```java
private String postByUpload() throws IOException {
        HttpClient httpClient = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost("http://127.0.0.1/api/open/test/post/upload");
        File file = new File("C:\\Users\\50381\\Desktop\\scrum8-dev.docx");
        MultipartEntityBuilder builder = MultipartEntityBuilder.create();
        builder.setCharset(Charset.forName("UTF-8"));
        // 文件流
        builder.addBinaryBody("doc", new FileInputStream(file), ContentType.MULTIPART_FORM_DATA, "scrum8");
        // 类似浏览器表单提交，对应input的name和value
        builder.addTextBody("fName","scrum8.docx");
        HttpEntity entity = builder.build();
        httpPost.setEntity(entity);
        HttpResponse response = httpClient.execute(httpPost);
        int code = response.getStatusLine().getStatusCode();
        if (code == HttpServletResponse.SC_OK) {
            return EntityUtils.toString(response.getEntity());
        }
        return null;
}
```
这里不要画蛇添足的手动指定`Header`，`MultipartEntityBuilder`会自动使用`multipart/form-data`方式
```java
httpPost.setHeader(new BasicHeader("Content-Type","multipart/form-data"));
```
因为这里是使用文件流上传，如果手动指定`multipart/form-data`方式后会因为找不到指定的文件流边界而报错
```java
Caused by: org.apache.tomcat.util.http.fileupload.FileUploadException: the request was rejected because no multipart boundary was found
```
