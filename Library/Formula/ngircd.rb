class Ngircd < Formula
  homepage "http://ngircd.barton.de"
  url "http://ngircd.barton.de/pub/ngircd/ngircd-22.tar.gz"
  mirror "http://ngircd.mirror.3rz.org/pub/ngircd/ngircd-22.tar.gz"
  sha256 "a08e18de52bcf09d35ce75a802204ecf000f32663c1c57ad930ebcd139bf4cc8"
  revision 1

  bottle do
    sha1 "1a370c58b671a989c69e30d0c93755a8f1f79995" => :mavericks
    sha1 "d79602eb6d27418d969e954513cc0870058109c3" => :mountain_lion
    sha1 "a863f046eb03353d881221fc6a6a725ab098de57" => :lion
  end

  option "with-iconv", "Enable character conversion using libiconv."
  option "with-pam", "Enable user authentication using PAM."

  # Older Formula used the next option by default, so keep it unless
  # deactivated by the user:
  option "without-ident", "Disable 'IDENT' ('AUTH') protocol support."

  depends_on "libident" if build.with? "ident"
  depends_on "openssl"

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{HOMEBREW_PREFIX}/etc
      --enable-ipv6
      --with-openssl
    ]

    args << "--with-iconv" if build.with? "iconv"
    args << "--with-ident" if build.with? "ident"
    args << "--with-pam" if build.with? "pam"

    system "./configure", *args
    system "make", "install"

    prefix.install "contrib/MacOSX/de.barton.ngircd.plist.tmpl" => "de.barton.ngircd.plist"
    (prefix+"de.barton.ngircd.plist").chmod 0644

    inreplace prefix+"de.barton.ngircd.plist" do |s|
      s.gsub! ":SBINDIR:", sbin
      s.gsub! "/Library/Logs/ngIRCd.log", var/"Logs/ngIRCd.log"
    end
  end

  test do
    # Exits non-zero, so test version and match Author's name supplied.
    assert_match /Alexander/, pipe_output("#{sbin}/ngircd -V 2>&1")
  end
end
