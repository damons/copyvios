<%!
    from flask import g, request
    from copyvios.checker import T_POSSIBLE, T_SUSPECT
    from copyvios.misc import cache
%>\
<%include file="/support/header.mako" args="title='Earwig\'s Copyvio Detector'"/>
<%namespace module="copyvios.highlighter" import="highlight_delta"/>\
<%namespace module="copyvios.misc" import="httpsfix, urlstrip"/>\
% if notice:
    <div id="notice-box" class="gray-box">
        ${notice}
    </div>
% endif
% if query.submitted:
    % if query.error:
        <div id="info-box" class="red-box"><p>
            % if query.error == "bad action":
                Unknown action: <b><span class="mono">${query.action | h}</span></b>.
            % elif query.error == "no search method":
                No copyvio search methods were selected. A check can only be made using a search engine, links present in the page, or both.
            % elif query.error == "no URL":
                URL comparison mode requires a URL to be entered. Enter one in the text box below, or choose copyvio search mode to look for content similar to the article elsewhere on the web.
            % elif query.error == "bad URI":
                Unsupported URI scheme: <a href="${query.url | h}">${query.url | h}</a>.
            % elif query.error == "no data":
                Couldn't find any text in <a href="${query.url | h}">${query.url | h}</a>. <i>Note:</i> only HTML documents, plain text pages, and PDFs are supported, and content generated by JavaScript or found inside iframes is ignored.
            % elif query.error == "timeout":
                The URL <a href="${query.url | h}">${query.url | h}</a> timed out before any data could be retrieved.
            % elif query.error == "search error":
                An error occurred while using the search engine (${query.exception}). Try reloading the page. If the error persists, <a href="${request.url | httpsfix, h}&amp;use_engine=0">repeat the check without using the search engine</a>.
            % else:
                An unknown error occurred.
            % endif
        </p></div>
    % elif not query.site:
        <div id="info-box" class="red-box">
            <p>The given site (project=<b><span class="mono">${query.project | h}</span></b>, language=<b><span class="mono">${query.lang | h}</span></b>) doesn't seem to exist. It may also be closed or private. <a href="//${query.lang | h}.${query.project | h}.org/">Confirm its URL.</a></p>
        </div>
    % elif query.oldid and not result:
        <div id="info-box" class="red-box">
            <p>The given revision ID doesn't seem to exist: <a href="//${query.site.domain | h}/w/index.php?oldid=${query.oldid | h}">${query.oldid | h}</a>.</p>
        </div>
    % elif query.title and not result:
        <div id="info-box" class="red-box">
            <p>The given page doesn't seem to exist: <a href="${query.page.url}">${query.page.title | h}</a>.</p>
        </div>
    % endif
%endif
<p>This tool attempts to detect <a href="//en.wikipedia.org/wiki/WP:COPYVIO">copyright violations</a> in articles. In search mode, it will check for similar content elsewhere on the web using <a href="//developer.yahoo.com/boss/search/">Yahoo! BOSS</a> and/or external links present in the text of the page, depending on which options are selected. In comparison mode, the tool will skip the searching step and display a report comparing the article to the given webpage, like the <a href="//tools.wmflabs.org/dupdet/">Duplication Detector</a>.</p>
<p>Running a full check can take up to 45 seconds if other websites are slow. Please be patient. If you get a timeout, wait a moment and refresh the page.</p>
<p>Specific websites can be skipped (for example, if their content is in the public domain) by being added to the <a href="//en.wikipedia.org/wiki/User:EarwigBot/Copyvios/Exclusions">excluded URL list</a>.</p>
<form id="cv-form" action="${request.script_root}" method="get">
    <table id="cv-form-outer">
        <tr>
            <td>Site:</td>
            <td colspan="3">
                <span class="mono">https://</span>
                <select name="lang">
                    <% selected_lang = query.orig_lang if query.orig_lang else g.cookies["CopyviosDefaultLang"].value if "CopyviosDefaultLang" in g.cookies else cache.bot.wiki.get_site().lang %>\
                    % for code, name in cache.langs:
                        % if code == selected_lang:
                            <option value="${code | h}" selected="selected">${name}</option>
                        % else:
                            <option value="${code | h}">${name}</option>
                        % endif
                    % endfor
                </select>
                <span class="mono">.</span>
                <select name="project">
                    <% selected_project = query.project if query.project else g.cookies["CopyviosDefaultProject"].value if "CopyviosDefaultProject" in g.cookies else cache.bot.wiki.get_site().project %>\
                    % for code, name in cache.projects:
                        % if code == selected_project:
                            <option value="${code | h}" selected="selected">${name}</option>
                        % else:
                            <option value="${code | h}">${name}</option>
                        % endif
                    % endfor
                </select>
                <span class="mono">.org</span>
            </td>
        </tr>
        <tr>
            <td id="cv-col1">Page&nbsp;title:</td>
            <td id="cv-col2">
                % if query.title:
                    <input class="cv-text" type="text" name="title" value="${query.page.title if query.page else query.title | h}" />
                % else:
                    <input class="cv-text" type="text" name="title" />
                % endif
            </td>
            <td id="cv-col3">or&nbsp;revision&nbsp;ID:</td>
            <td id="cv-col4">
                % if query.oldid:
                    <input class="cv-text" type="text" name="oldid" value="${query.oldid | h}" />
                % else:
                    <input class="cv-text" type="text" name="oldid" />
                % endif
            </td>
        </tr>
        <tr>
            <td>Action:</td>
            <td colspan="3">
                <table id="cv-form-inner">
                    <tr>
                        <td id="cv-inner-col1">
                            <input id="action-search" type="radio" name="action" value="search" ${'checked="checked"' if (query.action == "search" or not query.action) else ""} />
                        </td>
                        <td id="cv-inner-col2"><label for="action-search">Copyvio&nbsp;search:</label></td>
                        <td id="cv-inner-col3">
                            <input class="cv-search" type="hidden" name="use_engine" value="0" />
                            <input id="cv-cb-engine" class="cv-search" type="checkbox" name="use_engine" value="1" ${'checked="checked"' if (query.use_engine != "0") else ""} />
                            <label for="cv-cb-engine">Use&nbsp;search&nbsp;engine</label>
                            <input class="cv-search" type="hidden" name="use_links" value="0" />
                            <input id="cv-cb-links" class="cv-search" type="checkbox" name="use_links" value="1" ${'checked="checked"' if (query.use_links != "0") else ""} />
                            <label for="cv-cb-links">Use&nbsp;links&nbsp;in&nbsp;page</label>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <input id="action-compare" type="radio" name="action" value="compare" ${'checked="checked"' if query.action == "compare" else ""} />
                        </td>
                        <td><label for="action-compare">URL&nbsp;comparison:</label></td>
                        <td>
                            <input class="cv-compare cv-text" type="text" name="url"
                            % if query.url:
                                value="${query.url | h}"
                            % endif
                            />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        % if query.nocache or (result and result.cached):
            <tr>
                <td><label for="cb-nocache">Bypass&nbsp;cache:</label></td>
                <td colspan="3">
                    <input id="cb-nocache" type="checkbox" name="nocache" value="1" ${'checked="checked"' if query.nocache else ""}  />
                </td>
            </tr>
        % endif
        <tr>
            <td colspan="4">
                <button type="submit">Submit</button>
            </td>
        </tr>
    </table>
</form>
% if result:
    <div id="generation-time">
        Results
        % if result.cached:
            <a id="cv-cached" href="#">cached<span>To save time (and money), this tool will retain the results of checks for up to 72 hours. This includes the URLs of the checked sources, but neither their content nor the content of the article. Future checks on the same page (assuming it remains unchanged) will not involve additional search queries, but a fresh comparison against the source URL will be made. If the page is modified, a new check will be run.</span></a> from <abbr title="${result.cache_time}">${result.cache_age} ago</abbr>. Originally
        % endif
        generated in <span class="mono">${round(result.time, 3)}</span>
        % if query.action == "search":
            seconds using <span class="mono">${result.queries}</span> quer${"y" if result.queries == 1 else "ies"}.
        % else:
            seconds.
        % endif
        <a href="${request.script_root | h}?lang=${query.lang | h}&amp;project=${query.project | h}&amp;oldid=${query.oldid or query.page.lastrevid | h}&amp;action=${query.action | h}&amp;${"use_engine={0}&use_links={1}".format(int(query.use_engine not in ("0", "false")), int(query.use_links not in ("0", "false"))) if query.action == "search" else "" | h}${"url=" if query.action == "compare" else ""}${query.url if query.action == "compare" else "" | u}">Permalink.</a>
    </div>
    <div id="cv-result" class="${'red' if result.confidence >= T_SUSPECT else 'yellow' if result.confidence >= T_POSSIBLE else 'green'}-box">
        <table id="cv-result-head-table">
            <colgroup>
                <col>
                <col>
                <col>
            </colgroup>
            <tr>
                <td>
                    <a href="${query.page.url}">${query.page.title | h}</a>
                    % if query.oldid:
                        @<a href="//${query.site.domain | h}/w/index.php?oldid=${query.oldid | h}">${query.oldid | h}</a>
                    % endif
                    % if query.redirected_from:
                        <br />
                        <span id="redirected-from">Redirected from <a href="//${query.site.domain | h}/w/index.php?title=${query.redirected_from.title | u}&amp;redirect=no">${query.redirected_from.title | h}</a>. <a href="${request.url | httpsfix, h}&amp;noredirect=1">Check original.</a></span>
                    % endif
                </td>
                <td>
                    <div>
                        % if result.confidence >= T_SUSPECT:
                            Violation&nbsp;Suspected
                        % elif result.confidence >= T_POSSIBLE:
                            Violation&nbsp;Possible
                        % elif result.sources:
                            Violation&nbsp;Unlikely
                        % else:
                            No&nbsp;Violation
                        % endif
                    </div>
                    <div>${round(result.confidence * 100, 1)}%</div>
                    <div>confidence</div>
                </td>
                <td>
                    % if result.url:
                        <a href="${result.url | h}">${result.url | urlstrip, h}</a>
                    % else:
                        <span id="result-head-no-sources">No matches found.</span>
                    % endif
                </td>
            </tr>
        </table>
    </div>
    % if query.action == "search":
        <% skips = False %>
        <div id="sources-container">
            <div id="sources-title">Checked Sources</div>
            % if result.sources:
                <table id="cv-result-sources">
                    <colgroup>
                        <col>
                        <col>
                        <col>
                    </colgroup>
                    <tr>
                        <th>URL</th>
                        <th>Confidence</th>
                        <th>Compare</th>
                    </tr>
                    % for i, source in enumerate(result.sources):
                        <tr ${'class="source-default-hidden"' if i >= 10 else 'id="source-row-selected"' if i == 0 else ""}>
                            <td><a ${'id="source-selected"' if i == 0 else ""} class="source-url" href="${source.url | h}">${source.url | h}</a></td>
                            <td>
                                % if source.excluded:
                                    <span class="source-excluded">Excluded</span>
                                % elif source.skipped:
                                    <% skips = True %>
                                    <span class="source-skipped">Skipped</span>
                                % else:
                                    <span class="source-confidence ${"source-suspect" if source.confidence >= T_SUSPECT else "source-possible" if source.confidence >= T_POSSIBLE else "source-novio"}">${round(source.confidence * 100, 1)}%</span>
                                % endif
                            </td>
                            <td>
                                % if i == 0:
                                    <a href="#cv-chain-table">Compare</a>
                                % else:
                                    <a href="${request.script_root | h}?lang=${query.lang | h}&amp;project=${query.project | h}&amp;oldid=${query.oldid or query.page.lastrevid | h}&amp;action=compare&amp;url=${source.url | u}">Compare</a>
                                % endif
                            </td>
                        </tr>
                    % endfor
                </table>
            % else:
                <div class="cv-source-footer">
                    No sources checked.
                </div>
            % endif
            % if len(result.sources) > 10:
                <div id="cv-additional" class="cv-source-footer">
                    ${len(result.sources) - 10} URL${"s" if len(result.sources) > 11 else ""} with lower confidence hidden. <a id="show-additional-sources" href="#">Show them.</a>
                </div>
            % endif
            % if skips or result.possible_miss:
                <div class="cv-source-footer">
                    The search ended early because a match was found with high confidence. <a href="${request.url | httpsfix, h}&amp;noskip=1">Do a complete check.</a>
                </div>
            % endif
        </div>
    % endif
    <div id="cv-chain-container">
        <table id="cv-chain-table">
            <tr>
                <td class="cv-chain-cell">Article: <div class="cv-chain-detail"><p>${highlight_delta(result.article_chain, result.best.chains[1] if result.best else None)}</p></div></td>
                <td class="cv-chain-cell">Source: <div class="cv-chain-detail"><p>${highlight_delta(result.best.chains[0], result.best.chains[1]) if result.best else ""}</p></div></td>
            </tr>
        </table>
    </div>
% endif
<%include file="/support/footer.mako"/>
