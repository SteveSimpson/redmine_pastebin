# redmine_pastebin -- A real pastebin plugin for Redmine.
#
# Copyright (C) 2011  Alex Shuglin <ash@commandprompt.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

module PastesHelper
  PASTEBIN_LANGS =  ["Plain Text", "Apache Config", "Bash", "C", "C++", "CSS", "CoffeeScript",
                     "Diff", "Git","Go","HAML", "JSON", "Java", "JavaScript", "Markdown",
                     "Markup", "Nginx","PHP", "Perl", "Python", "Ruby", "SQL", "XML", "YAML"]

  # This maps pretty language/syntax name to identifier that PrismJS
  # can understand.  If a language is not mapped, unchanged name is
  # assumed for the scanner.
  PASTEBIN_SCANNERS_MAP = {
    'Plain Text' => 'Plaintext',
    'Markup' => 'markup',
    'CSS' => 'css',
    'Apache Config' => 'apacheconf',
    'Bash' => 'bash',
    'CoffeeScript' => 'coffeescript',
    'Git' => 'git',
    'Go' => 'go',
    'HAML' => 'haml',
    'JSON' => 'json',
    'Markdown' => 'markdown',
    'Nginx' => 'nginx',
    'Perl' => 'perl',
    'C' => 'c',
    'Java' => 'java',
    'JavaScript' => 'javascript',
    'Python' => 'python',
    'Ruby' => 'ruby',
    'PHP' => 'php',
    'SQL' => 'sql',
    'XML' => 'xml',
    'Diff' => 'diff',
    'YAML' => 'yaml',
    'C++' => 'cpp'
  }

  PASTEBIN_MIME_TYPES_MAP = {
    'Plain Text' => 'text/plain',
    'C' => 'text/x-c',
    'Ruby' => 'text/x-ruby',
    'PHP' => 'text/x-php',
    'XML' => 'application/xml',
    'python' => 'text/x-python',
    'markdown' => 'text/x-markdown',
    'bash' => 'text/x-shellscript',
    'coffeescript' => 'application/vnd.coffeescript'
  }

  PASTEBIN_FILE_SUFFIX_MAP = {
    'Plain Text' => 'txt',
    'Plaintext' => 'txt',
    'git' => 'txt',
    'markup' => 'txt',
    'C++' => 'cpp',
    'JavaScript' => 'js',
    'Python' => 'py',
    'Ruby' => 'rb',
    'ruby' => 'rb',
    'python' => 'py',
    'coffeescript' => 'coffee',
    'bash' => 'sh',
    'markdown' => 'md',
    'perl' => 'pl',
    'javascript' => 'js',
    'nginx' => 'conf',
    'apacheconf' => 'conf'

  }

  PASTEBIN_EXPIRATION_CHOICES = [[:never, 0], [:an_hour, 1.hour], [:a_day, 1.day]]

  def pastebin_lang_to_scanner(lang)
    PASTEBIN_SCANNERS_MAP[lang] || lang
  end

  def pastebin_language_name(lang)
    PASTEBIN_SCANNERS_MAP.invert[lang] || lang
  end

  def pastebin_language_choices
    PASTEBIN_LANGS.map { |v| [v, pastebin_lang_to_scanner(v)] }
  end

  def pastebin_expiration_choices
    PASTEBIN_EXPIRATION_CHOICES.map { |x| [translate(:"paste_expires_in_#{x.first}"), x.last] }
  end

  def pastebin_filename_suffix(paste)
    PASTEBIN_FILE_SUFFIX_MAP[paste.lang] || paste.lang.downcase
  end

  def pastebin_filename(paste)
    paste.title + "." + pastebin_filename_suffix(paste)
  end

  def pastebin_mime_type(paste)
    PASTEBIN_MIME_TYPES_MAP[paste.lang] || "application/octet-stream"
  end

  def highlighted_content_for_paste(paste)
    content_tag :pre do
      content_tag :code, :class => "language-#{pastebin_lang_to_scanner(paste.lang)} line-numbers" do
        paste.text
      end
    end
  end

  def paste_timestamp(paste)
    content_tag :span, :class => "timestamp" do
      paste.created_on.to_s(:db)
    end
  end

  def url_to_paste(action, paste = nil)
    { :controller => "pastes", :action => action,
      :id => paste, :project_id => @project }
  end

  def link_to_paste(paste)
    link_to(paste.title, paste)
  end

  def edit_paste_link(paste, title = l(:button_edit))
    link_to_if_authorized(title, url_to_paste("edit", paste),
                          :class => "icon icon-edit")
  end

  def delete_paste_link(paste, title = l(:button_delete))
    link_to_if_authorized(title, url_to_paste("destroy", paste),
                          :class => "icon icon-del",
                          :method => :delete,
                          data: {confirm: l(:text_paste_delete_confirmation)})
  end

  def download_paste_link(paste, title = l(:button_download))
    link_to(title, url_to_paste("download", paste),
            :class => "icon icon-save")
  end

  def manage_paste_links(paste)
    [edit_paste_link(paste),
     delete_paste_link(paste),
     download_paste_link(paste)].join("\n").html_safe
  end

  def link_to_all_pastes
    link_to(l(:label_paste_view_all), url_to_paste("index"),
            :class => "icon icon-multiple")
  end

  def link_to_new_paste
    link_to_if_authorized(l(:label_paste_new), url_to_paste("new"),
                          :class => "icon icon-add")
  end
end
