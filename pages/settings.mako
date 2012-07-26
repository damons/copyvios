<% bot, status, langs, projects = main(environ, headers, cookies) %>\
<%include file="/support/header.mako" args="environ=environ, cookies=cookies, title='Settings'"/>\
<%namespace module="toolserver.settings" import="main"/>\
<%! from json import dumps, loads %>
            % if status:
                <div class="green-box">
                    <p>${status}</p>
                </div>
            % endif
            <h1>Settings</h1>
            <p>This page contains some configurable options for this Toolserver site. Settings are saved as cookies. You can view and delete all cookies generated by this site at the bottom of this page.</p>
            <form action="${environ['PATH_INFO']}" method="post">
                <input type="hidden" name="action" value="set">
                <table>
                    <tr>
                        <td>Default site:</td>
                        <td>
                            <tt>http://</tt>
                            <select name="lang">
                                <% selected_lang = cookies["EarwigDefaultLang"].value if "EarwigDefaultLang" in cookies else bot.wiki.get_site().lang %>
                                % for code, name in langs:
                                    % if code == selected_lang:
                                        <option value="${code | h}" selected="selected">${name}</option>
                                    % else:
                                        <option value="${code | h}">${name}</option>
                                    % endif
                                % endfor
                            </select>
                            <tt>.</tt>
                            <select name="project">
                                <% selected_project = cookies["EarwigDefaultProject"].value if "EarwigDefaultProject" in cookies else bot.wiki.get_site().project %>
                                % for code, name in projects:
                                    % if code == selected_project:
                                        <option value="${code | h}" selected="selected">${name}</option>
                                    % else:
                                        <option value="${code | h}">${name}</option>
                                    % endif
                                % endfor
                            </select>
                            <tt>.org</tt>
                        </td>
                    </tr>
                    <%
                        background_options = [
                            ("plain-brown", "Use a plain tiled background (brown version)."),
                            ("plain-blue", "Use a plain tiled background (blue version)."),
                            ("potd", 'Use the current <a href="//commons.wikimedia.org/">Wikimedia Commons</a> <a href="//commons.wikimedia.org/wiki/Commons:Picture_of_the_day">Picture of the Day</a>, unfiltered. Certain POTDs may be unsuitable as backgrounds due to their aspect ratio or subject matter (generally portraits do not work well).'),
                            ("list", 'Randomly select from <a href="http://commons.wikimedia.org/wiki/User:The_Earwig/POTD">a subset of previous Commons Pictures of the Day</a> that work well as widescreen backgrounds, refreshed daily (default).'),
                        ]
                        selected = cookies["EarwigBackground"].value if "EarwigBackground" in cookies else "list"
                    %>
                    % for i, (value, desc) in enumerate(background_options):
                        <tr>
                            % if i == 0:
                                <td>Background:</td>
                            % else:
                                <td>&nbsp;</td>
                            % endif
                            <td>
                                <input type="radio" name="background" value="${value}" ${'checked' if value == selected else ''} /> ${desc}
                            </td>
                        </tr>
                    % endfor
                    <tr>
                        <td><button type="submit">Save</button></td>
                    </tr>
                </table>
            </form>
            <h2>Cookies</h2>
            % if cookies:
                <table>
                <% cookie_order = ["EarwigDefaultProject", "EarwigDefaultLang", "EarwigBackground", "EarwigCVShowDetails", "EarwigBackgroundCache"] %>\
                % for key in [key for key in cookie_order if key in cookies]:
                    <% cookie = cookies[key] %>\
                    <tr>
                        <td><b><tt>${key | h}</tt></b></td>
                        % try:
                            <% lines = dumps(loads(cookie.value), indent=4).splitlines() %>
                            <td>
                                % for line in lines:
                                    <tt><div class="indentable">${line | h}</div></tt>
                                % endfor
                            </td>
                        % except ValueError:
                            <td><tt>${cookie.value | h}</tt></td>
                        % endtry
                        <td>
                            <form action="${environ['PATH_INFO']}" method="post">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="cookie" value="${key | h}">
                                <button type="submit">Delete</button>
                            </form>
                        </td>
                    </tr>
                % endfor
                    <tr>
                        <td>
                            <form action="${environ['PATH_INFO']}" method="post">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="all" value="1">
                                <button type="submit">Delete all</button>
                            </form>
                        </td>
                    </tr>
                </table>
            % else:
                <p>No cookies!</p>
            % endif
<%include file="/support/footer.mako" args="environ=environ, cookies=cookies"/>
