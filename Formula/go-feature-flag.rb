class GoFeatureFlag < Formula
  desc "Simple, complete, and lightweight feature flag solution"
  homepage "https://gofeatureflag.org"
  url "https://github.com/thomaspoignant/go-feature-flag/archive/refs/tags/v1.15.0.tar.gz"
  sha256 "96d29dad09aa5fe30cfd1bf87ad44a4e1d0084f7881a2d8bbb4a512ddab4b408"
  license "MIT"
  head "https://github.com/thomaspoignant/go-feature-flag.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "6b8c28403b59fb34d9f3f1f02ca26bed9a0306426a76df2e120823442a95de41"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "6b8c28403b59fb34d9f3f1f02ca26bed9a0306426a76df2e120823442a95de41"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "6b8c28403b59fb34d9f3f1f02ca26bed9a0306426a76df2e120823442a95de41"
    sha256 cellar: :any_skip_relocation, ventura:        "a1bec9114785a333a1136fb6c14eebd08179a98187a9c26e091694540b3bda69"
    sha256 cellar: :any_skip_relocation, monterey:       "a1bec9114785a333a1136fb6c14eebd08179a98187a9c26e091694540b3bda69"
    sha256 cellar: :any_skip_relocation, big_sur:        "a1bec9114785a333a1136fb6c14eebd08179a98187a9c26e091694540b3bda69"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "b3e3b5b1701986892aee948fcfb03652cc996429d985eefb99346796a11e40aa"
  end

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X main.version=#{version}"
    system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/relayproxy"
  end

  test do
    port = free_port

    (testpath/"flags.yml").write <<~EOS
      test-flag:
        variations:
          true-var: true
          false-var: false
        defaultRule:
          variation: true-var
    EOS

    (testpath/"test.yml").write <<~EOS
      listen: #{port}
      pollingInterval: 1000
      retriever:
        kind: file
        path: #{testpath}/flags.yml
    EOS

    begin
      pid = fork do
        exec bin/"go-feature-flag", "--config", "#{testpath}/test.yml"
      end
      sleep 3

      expected_output = /true/

      assert_match expected_output, shell_output("curl -s http://localhost:#{port}/health")
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
