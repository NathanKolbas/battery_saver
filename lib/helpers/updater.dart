import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

const gitHubUserName = 'NathanKolbas';
const gitHubRepoName = 'battery_saver';

enum GitHubUpdaterCheckUpdateResponse {
  notFound,
  upToDate,
  update;
}

class GitHubUpdaterCheckUpdate {
  final GitHubUpdaterCheckUpdateResponse response;
  final String version;
  final String name;
  final String body;
  final String downloadUrl;
  final String releaseUrl;

  GitHubUpdaterCheckUpdate({
    required this.response,
    this.version = '',
    this.name = '',
    this.body = '',
    this.downloadUrl = '',
    this.releaseUrl = '',
  });
}

class GitHubUpdater {
  final String userName;
  final String repoName;

  GitHubUpdater({
    this.repoName = gitHubRepoName,
    this.userName = gitHubUserName,
  });

  String get gitHubReleaseUrl => "https://api.github.com/repos/$userName/$repoName/releases";
  String get gitHubLatestReleaseUrl => "$gitHubReleaseUrl/latest";
  String gitHubReleaseTagUrl(String tag) => "$gitHubReleaseUrl/tags/$tag";

  Future<Map> fetchGithubReleaseLatest() async {
    final response = await http.get(Uri.parse(gitHubLatestReleaseUrl));
    final decodedResponse = jsonDecode(response.body) as Map;
    return decodedResponse;
  }

  Future<Map> fetchGithubReleaseForTag(String tag) async {
    final response = await http.get(Uri.parse(gitHubReleaseTagUrl(tag)));
    final decodedResponse = jsonDecode(response.body) as Map;
    return decodedResponse;
  }

  Future<GitHubUpdaterCheckUpdate> checkForUpdate() async {
    final latest = await fetchGithubReleaseLatest();
    if (kDebugMode) print(latest);
    if (latest['message'] == 'Not Found') {
      // No release found
      return GitHubUpdaterCheckUpdate(response: GitHubUpdaterCheckUpdateResponse.notFound);
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    final tagName = latest['tag_name'] as String;
    final body = latest['body'] as String;
    final releaseUrl = latest['html_url'];

    if (version == tagName) {
      // Up to date
      return GitHubUpdaterCheckUpdate(response: GitHubUpdaterCheckUpdateResponse.upToDate);
    }

    for (final asset in latest['assets']) {
      final name = asset['name'] as String;
      if (asset['content_type'] == 'application/vnd.android.package-archive') {
        final downloadUrl = asset['browser_download_url'];
        return GitHubUpdaterCheckUpdate(
          response: GitHubUpdaterCheckUpdateResponse.update,
          version: tagName,
          name: name,
          body: body,
          downloadUrl: downloadUrl,
          releaseUrl: releaseUrl,
        );
      }
    }

    return GitHubUpdaterCheckUpdate(response: GitHubUpdaterCheckUpdateResponse.notFound);
  }

  Future<String?> getReleaseNotesForTag(String tag) async {
    final release = await fetchGithubReleaseForTag(tag);
    if (kDebugMode) print(release);
    return release['body'] as String?;
  }

  updateSnackBar(BuildContext context, bool mounted, {bool showNoUpdate=false}) async {
    final data = await checkForUpdate();
    String content = '';
    switch (data.response) {
      case GitHubUpdaterCheckUpdateResponse.notFound:
        if (!showNoUpdate) return;

        content = 'No update found';
        break;
      case GitHubUpdaterCheckUpdateResponse.upToDate:
        if (!showNoUpdate) return;

        content = 'Up to date';
        break;
      case GitHubUpdaterCheckUpdateResponse.update:
        content = 'New update available';
        break;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(content),
      dismissDirection: DismissDirection.horizontal,
      action: data.response == GitHubUpdaterCheckUpdateResponse.update ? SnackBarAction(
        onPressed: () => launchUrlString(data.releaseUrl, mode: LaunchMode.externalApplication),
        label: 'Download',
      ) : null,
    ));
  }
}
