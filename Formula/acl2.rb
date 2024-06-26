class Acl2 < Formula
  desc "Logic and programming language in which you can model computer systems"
  homepage "https://www.cs.utexas.edu/users/moore/acl2/index.html"
  url "https://github.com/acl2/acl2/archive/8.3.tar.gz"
  sha256 "45eedddb36b2eff889f0dba2b96fc7a9b1cf23992fcfdf909bc179f116f2c5ea"
  license "BSD-3-Clause"
  revision 5

  bottle do
    sha256 "47d523299e219e13e26adb3e3cc4d2eb984e9d535ef242bf16ee4c92229b63aa" => :big_sur
    sha256 "8bfb7ce324dfa93e6d8f46acaafbf69be4ed400c101371af97aa6ff7d9503469" => :catalina
    sha256 "547ba61b3a0514bd55ff3a04b19c4e5792ec19eb64f46cbb672bf30ffd871b93" => :mojave
  end

  depends_on "gnu-sed" => :build
  depends_on "clozure-cl"
  depends_on "openssl@1.1"
  depends_on "z3"

  def install
    system "make",
      "LISP=#{Formula["clozure-cl"].opt_bin}/ccl64",
      "ACL2_PAR=p",
      "ACL2_REAL=r",
      "ACL2=#{buildpath}/saved_acl2pr",
      "USE_QUICKLISP=1",
      "all", "basic"
    system Formula["gnu-sed"].opt_bin/"sed",
      "-i", "s%/tmp/.*/saved_acl2pr%#{libexec}/saved_acl2pr%",
      buildpath/"saved_acl2pr"
    libexec.install Dir["*"]
    bin.install_symlink libexec/"saved_acl2pr" => "acl2"
  end

  test do
    (testpath/"simple.lisp").write "(+ 2 2)"
    output = shell_output("#{bin}/acl2 < #{testpath}/simple.lisp | grep 'ACL2(r) !>'")
    assert_equal "ACL2(r) !>4\nACL2(r) !>Bye.", output.strip
  end
end
