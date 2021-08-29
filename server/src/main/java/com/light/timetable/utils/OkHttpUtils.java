package com.light.timetable.utils;


import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import java.io.*;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

public class OkHttpUtils {
    private static final byte[] EMPTY_BYTES = new byte[0];

    /**
     * 静态内部类单例模式
     * 需要时加载
     * <p>
     * 只有第一次调用getInstance方法时，
     * 虚拟机才加载 Inner 并初始化okHttpClient，
     * 只有一个线程可以获得对象的初始化锁，其他线程无法进行初始化，
     * 保证对象的唯一性。目前此方式是所有单例模式中最推荐的模式。
     */
    private static class Inner {
        private static OkHttpClient okHttpClient = new OkHttpClient.Builder()
                .connectTimeout(5, TimeUnit.SECONDS)
                .readTimeout(5, TimeUnit.SECONDS)
                .writeTimeout(5, TimeUnit.SECONDS)
                .followRedirects(true)
                .build();
    }

    public static OkHttpClient getOkHttpClient() {
        return Inner.okHttpClient;
    }

    public static void setFollowRedirects(boolean followRedirects) {
        if (Inner.okHttpClient.followRedirects() != followRedirects) {
            Inner.okHttpClient = Inner.okHttpClient.newBuilder()
                    .followRedirects(followRedirects)
                    .build();
        }
    }

    /**
     * 下载文件到本地
     *
     * @param url  网址
     * @param path 文件夹地址
     * @param name 文件名
     * @return 是否成功
     */
    public static boolean downloadToLocal(String url, String path, String name) {
        return downloadToLocal(createRequest(url), path, name);
    }

    /**
     * 下载文件到本地
     *
     * @param path 文件夹地址
     * @param name 文件名
     * @return 是否下载成功
     */
    public static boolean downloadToLocal(Request request, String path, String name) {
        BufferedInputStream bis = null;
        BufferedOutputStream bos = null;
        try (Response response = getOkHttpClient().newCall(request).execute()) {
            if (response.code() == 200) {
                if (response.body() == null) {
                    return false;
                }

                File file = new File(path);
                if (!file.exists()) {
                    if (!file.mkdirs()) {
                        System.out.println(path + "路径创建失败");
                    }
                } else {
                    if (!file.isDirectory()) {
                        return false;
                    }
                }

                bos = new BufferedOutputStream(
                        new FileOutputStream(new File(file, name)));
                bis = new BufferedInputStream(Objects.requireNonNull(response.body()).byteStream());

                byte[] buffer = new byte[1024];
                int len;
                while ((len = bis.read(buffer, 0, 1024)) != -1) {
                    bos.write(buffer, 0, len);
                }
                bos.flush();

                return true;
            }
        } catch (IOException | NullPointerException e) {
            e.printStackTrace();
        } finally {
            try {
                if (bis != null) {
                    bis.close();
                }
                if (bos != null) {
                    bos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }

        }
        return false;
    }

    /**
     * 下载文本内容
     *
     * @param url 网址
     * @return 下载文本
     */
    public static String downloadText(String url) {
        return downloadText(createRequest(url));
    }

    /**
     * 下载文本内容
     *
     * @param request
     * @return
     */
    public static String downloadText(Request request) {
        return downloadText(request, "UTF-8");
    }

    /**
     * 下载文本内容
     *
     * @param url
     * @return
     */
    public static String downloadText(String url, String encoding) {
        return downloadText(createRequest(url), encoding);
    }

    /**
     * 下载文本内容
     *
     * @param request
     * @param encoding
     * @return
     */
    public static String downloadText(Request request, String encoding) {
        try {
            return new String(downloadRaw(request), encoding);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return "";
        }
    }

    /**
     * 下载字节码
     *
     * @param url
     * @return
     */
    public static byte[] downloadRaw(String url) {
        return downloadRaw(createRequest(url));
    }

    /**
     * 下载字节码
     *
     * @param request
     * @return 返回下载内容
     */
    public static byte[] downloadRaw(Request request) {
        try (Response response = getOkHttpClient().newCall(request).execute()) {
            if (response.code() == 200 && response.body() != null) {
                return Optional.ofNullable(response.body())
                        .map(body -> {
                            try {
                                return body.bytes();
                            } catch (IOException e) {
                                e.printStackTrace();
                                return null;
                            }
                        })
                        .orElse(EMPTY_BYTES);
            }
        } catch (IOException | NullPointerException e) {
            e.printStackTrace();
        }
        return EMPTY_BYTES;
    }

    /**
     * 生成request
     *
     * @param url 网址
     * @return
     */
    public static Request createRequest(String url) {
        return new Request.Builder()
                .url(url)
                .build();
    }

    public static Request createRequest(String url, String cookies) {
        return new Request.Builder()
                .url(url)
                .addHeader("cookie", cookies)
                .build();
    }
}
